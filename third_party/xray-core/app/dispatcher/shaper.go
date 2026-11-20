package dispatcher

import (
	"os"

	"github.com/xtls/xray-core/common"
	"github.com/xtls/xray-core/common/buf"
)

// shaperWriter paces one direction of a link.
//
// The write stays on the producer's goroutine — Xray's link writers are not
// safe to call from another goroutine. The bucket is charged first, then the
// buffers go straight through in their natural size.
//
// Earlier revisions batched data until 64 KiB had accumulated. That deadlocks
// request/response flows: the TLS handshake's first flight is a few KiB, the
// peer blocks waiting for it, and the batch never fills, so nothing moves at
// all. The initial burst covers handshakes, and the pacing sleep between
// chunks is what throttles the bulk transfer.
type shaperWriter struct {
	target buf.Writer
	limit  *tokenBucket
}

func newShaperWriter(target buf.Writer, limit *tokenBucket) *shaperWriter {
	return &shaperWriter{target: target, limit: limit}
}

func (s *shaperWriter) WriteMultiBuffer(mb buf.MultiBuffer) error {
	if n := int(mb.Len()); n > 0 {
		s.limit.wait(n)
	}
	return s.target.WriteMultiBuffer(mb)
}

func (s *shaperWriter) Interrupt() {
	common.Interrupt(s.target)
}

func (s *shaperWriter) Close() error {
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
