package dispatcher

import (
	"os"

	"github.com/xtls/xray-core/common"
	"github.com/xtls/xray-core/common/buf"
)

// shaperWriter paces one direction of a link.
//
// The write stays on the producer's goroutine — Xray's link writers are not
// safe to call from another goroutine — but the bytes are batched before the
// write. Handing the target 8 KiB at a time makes it emit tiny TLS records and
// the peer's delayed ACK stalls every one of them, which caps the link far
// below the configured rate. Batching keeps the record size natural.
//
// The producer still stalls while the bucket refills, but only once per batch,
// and the socket buffers absorb the difference.
type shaperWriter struct {
	target  buf.Writer
	limit   *tokenBucket
	pending buf.MultiBuffer
}

// shaperBatchBytes is the release granularity.
const shaperBatchBytes = 64 * 1024

func newShaperWriter(target buf.Writer, limit *tokenBucket) *shaperWriter {
	return &shaperWriter{target: target, limit: limit}
}

func (s *shaperWriter) WriteMultiBuffer(mb buf.MultiBuffer) error {
	s.pending = append(s.pending, mb...)
	for int32(s.pending.Len()) >= shaperBatchBytes {
		// SplitSize returns (remaining, chunk).
		rest, chunk := buf.SplitSize(s.pending, shaperBatchBytes)
		s.pending = rest
		s.limit.wait(int(chunk.Len()))
		if err := s.target.WriteMultiBuffer(chunk); err != nil {
			buf.ReleaseMulti(rest)
			return err
		}
	}
	return nil
}

func (s *shaperWriter) Interrupt() {
	common.Interrupt(s.target)
}

func (s *shaperWriter) Close() error {
	if s.pending.Len() > 0 {
		s.limit.wait(int(s.pending.Len()))
		pending := s.pending
		s.pending = nil
		if err := s.target.WriteMultiBuffer(pending); err != nil {
			return err
		}
	}
	return common.Close(s.target)
}

// shaperReader paces the other direction. Uploads are small, so a blocking
// read is enough and avoids a second buffer queue.
type shaperReader struct {
	reader buf.Reader
	limit  *tokenBucket
}

func newShaperReader(reader buf.Reader, limit *tokenBucket) *shaperReader {
	return &shaperReader{reader: reader, limit: limit}
}

func (r *shaperReader) ReadMultiBuffer() (buf.MultiBuffer, error) {
	mb, err := r.reader.ReadMultiBuffer()
	if mb != nil {
		r.limit.wait(int(mb.Len()))
	}
	return mb, err
}

func (r *shaperReader) Interrupt() {
	common.Interrupt(r.reader)
}

// debugEnabled reports whether the limiter should print its counters.
func debugEnabled() bool {
	return os.Getenv("XRAY_RATELIMIT_DEBUG") != ""
}
