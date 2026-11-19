import { useEffect, useState } from 'react';
import type { ComponentProps } from 'react';
import { Modal, Spin } from 'antd';
import { useTranslation } from 'react-i18next';

import { useClients } from '@/hooks/useClients';
import type { ClientRecord, ExternalLink, InboundOption } from '@/schemas/client';

import ClientFormModal from './ClientFormModal';

interface Props {
  open: boolean;
  email: string | null;
  inbounds: InboundOption[];
  groups: string[];
  tgBotEnable: boolean;
  onOpenChange: (open: boolean) => void;
  onSaved?: () => void;
}

type SaveFn = ComponentProps<typeof ClientFormModal>['save'];

// Full client editor for the inbound page: hydrates the paged row into the
// complete record first, then reuses ClientFormModal so every protocol field,
// inbound attachment and external link stays available outside the clients page.
export default function ClientEditModal({
  open,
  email,
  inbounds,
  groups,
  tgBotEnable,
  onOpenChange,
  onSaved,
}: Props) {
  const { t } = useTranslation();
  const { hydrate, update, attach, detach, setExternalLinks, resetTraffic } = useClients({
    list: false,
  });
  const [client, setClient] = useState<ClientRecord | null>(null);
  const [attachedIds, setAttachedIds] = useState<number[]>([]);
  const [externalLinks, setLinks] = useState<ExternalLink[]>([]);
  const [tunnelAllowedIPs, setTunnelAllowedIPs] = useState<Record<number, string>>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!open || !email) return;
    let alive = true;
    hydrate(email)
      .then((full) => {
        if (!alive) return;
        if (full) {
          setClient(full.client);
          setAttachedIds(Array.isArray(full.inboundIds) ? full.inboundIds : []);
          setLinks(Array.isArray(full.externalLinks) ? full.externalLinks : []);
          setTunnelAllowedIPs(full.tunnelAllowedIPs ?? {});
        }
      })
      .finally(() => {
        if (alive) setLoading(false);
      });
    return () => {
      alive = false;
    };
  }, [open, email, hydrate]);

  const onSave: SaveFn = async (payload, meta) => {
    if (!meta.isEdit) return null;
    const msg = await update(meta.email, payload);
    if (!msg?.success) return msg;
    const rawEmail = (payload as { email?: unknown }).email;
    const emailKey = typeof rawEmail === 'string' && rawEmail.trim() ? rawEmail.trim() : meta.email;
    if (meta.attach.length > 0) {
      const r = await attach(emailKey, meta.attach);
      if (!r?.success) return r;
    }
    if (meta.detach.length > 0) {
      const r = await detach(emailKey, meta.detach);
      if (!r?.success) return r;
    }
    const linked = await setExternalLinks(emailKey, meta.externalLinks);
    if (!linked?.success) return linked;
    onSaved?.();
    return msg;
  };

  if (open && (loading || !client)) {
    return (
      <Modal
        open
        footer={null}
        title={t('pages.clients.editClient')}
        onCancel={() => onOpenChange(false)}
      >
        <div style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
          <Spin />
        </div>
      </Modal>
    );
  }

  return (
    <ClientFormModal
      open={open && !!client}
      mode="edit"
      client={client}
      inbounds={inbounds}
      attachedIds={attachedIds}
      attachedExternalLinks={externalLinks}
      tunnelAllowedIPs={tunnelAllowedIPs}
      groups={groups}
      tgBotEnable={tgBotEnable}
      save={onSave}
      resetTraffic={resetTraffic}
      onOpenChange={onOpenChange}
    />
  );
}
