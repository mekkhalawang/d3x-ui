import { useMemo, useState } from 'react';
import type { ComponentProps } from 'react';
import {
  App,
  Button,
  DatePicker,
  Empty,
  Modal,
  Popconfirm,
  Switch,
  Table,
  Tag,
  Tooltip,
} from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { DeleteOutlined, EditOutlined, PlusOutlined } from '@ant-design/icons';
import dayjs, { type Dayjs } from 'dayjs';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router';

import { HttpUtil, SizeFormatter } from '@/utils';
import { coerceInboundJsonField } from '@/models/dbinbound';
import { useClients } from '@/hooks/useClients';
import ClientFormModal from '@/pages/clients/ClientFormModal';

import type { DBInboundRecord } from './types';

// Protocols whose settings carry a per-client list. WireGuard keeps peers,
// MTProto/TUIC run sidecars with their own model, so they stay collapsed.
const CLIENT_LIST_PROTOCOLS = new Set(['vless', 'vmess', 'trojan', 'shadowsocks', 'hysteria']);

interface RawClient {
  email: string;
  enable?: boolean;
  totalGB?: number;
  expiryTime?: number;
  speedLimitUp?: number;
  speedLimitDown?: number;
  comment?: string;
}

export function canExpandInbound(record: Pick<DBInboundRecord, 'protocol'>): boolean {
  return CLIENT_LIST_PROTOCOLS.has(String(record.protocol).toLowerCase());
}

interface Props {
  inbound: DBInboundRecord;
  onChanged?: () => void;
}

type SaveFn = ComponentProps<typeof ClientFormModal>['save'];

export default function InboundClientsPanel({ inbound, onChanged }: Props) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { message } = App.useApp();
  const { create, setExternalLinks, inbounds, allGroups, tgBotEnable } = useClients();
  const [busy, setBusy] = useState<string | null>(null);
  const [addOpen, setAddOpen] = useState(false);
  const [expiryEdit, setExpiryEdit] = useState<{ email: string; value: Dayjs | null } | null>(null);

  const clients = useMemo<RawClient[]>(() => {
    const settings = coerceInboundJsonField(inbound.settings);
    const list = settings.clients;
    if (!Array.isArray(list)) return [];
    return list.filter((c): c is RawClient => !!c && typeof c === 'object' && 'email' in c);
  }, [inbound.settings]);

  const statsByEmail = useMemo(() => {
    const map = new Map<string, { up: number; down: number; total: number }>();
    for (const s of inbound.clientStats || []) map.set(s.email, s);
    return map;
  }, [inbound.clientStats]);

  const call = async (key: string, url: string, body?: unknown) => {
    setBusy(key);
    try {
      const msg = await HttpUtil.post(url, body);
      if (msg?.success) {
        onChanged?.();
        return true;
      }
      message.error(msg?.msg || t('somethingWentWrong'));
      return false;
    } finally {
      setBusy(null);
    }
  };

  const toggle = (client: RawClient, enable: boolean) =>
    call(
      `toggle:${client.email}`,
      `/panel/api/clients/update/${encodeURIComponent(client.email)}`,
      {
        enable,
      },
    );

  const remove = (client: RawClient) =>
    call(`del:${client.email}`, `/panel/api/clients/del/${encodeURIComponent(client.email)}`);

  const saveExpiry = async () => {
    if (!expiryEdit) return;
    const expiryTime = expiryEdit.value ? expiryEdit.value.valueOf() : 0;
    const ok = await call(
      `expiry:${expiryEdit.email}`,
      `/panel/api/clients/update/${encodeURIComponent(expiryEdit.email)}`,
      { expiryTime },
    );
    if (ok) setExpiryEdit(null);
  };

  // Same create contract as the clients page: the modal owns every field, the
  // backend fills protocol defaults, and external links are a second call.
  const onSave: SaveFn = async (payload, meta) => {
    if (meta.isEdit) return null;
    const msg = await create(payload);
    if (!msg?.success) return msg;
    if (meta.email && meta.externalLinks.length > 0) {
      const linked = await setExternalLinks(meta.email, meta.externalLinks);
      if (!linked?.success) return linked;
    }
    onChanged?.();
    return msg;
  };

  const columns: ColumnsType<RawClient> = [
    {
      title: t('pages.inbounds.enable'),
      width: 64,
      render: (_, client) => (
        <Switch
          size="small"
          checked={client.enable !== false}
          loading={busy === `toggle:${client.email}`}
          onChange={(next) => toggle(client, next)}
          aria-label={t('pages.inbounds.enable')}
        />
      ),
    },
    {
      title: t('pages.inbounds.client'),
      ellipsis: true,
      render: (_, client) => (
        <div className="client-cell">
          <span className="client-email">{client.email}</span>
          {client.comment ? <span className="client-comment">{client.comment}</span> : null}
        </div>
      ),
    },
    {
      title: t('pages.inbounds.traffic'),
      width: 180,
      render: (_, client) => {
        const stat = statsByEmail.get(client.email);
        const used = (stat?.up || 0) + (stat?.down || 0);
        const total = client.totalGB || 0;
        return (
          <Tooltip
            title={`↑${SizeFormatter.sizeFormat(stat?.up || 0)}  ↓${SizeFormatter.sizeFormat(stat?.down || 0)}`}
          >
            <span>
              {SizeFormatter.sizeFormat(used)}
              {total > 0 ? ` / ${SizeFormatter.sizeFormat(total)}` : ' / ∞'}
            </span>
          </Tooltip>
        );
      },
    },
    {
      title: t('pages.inbounds.expireDate'),
      width: 150,
      render: (_, client) => {
        const expiry = client.expiryTime || 0;
        return (
          <Button
            type="link"
            size="small"
            style={{ padding: 0 }}
            onClick={() =>
              setExpiryEdit({ email: client.email, value: expiry > 0 ? dayjs(expiry) : null })
            }
          >
            {expiry > 0 ? dayjs(expiry).format('YYYY-MM-DD HH:mm') : t('unlimited')}
          </Button>
        );
      },
    },
    {
      title: t('pages.inbounds.speedLimit'),
      width: 120,
      render: (_, client) => {
        const up = client.speedLimitUp || 0;
        const down = client.speedLimitDown || 0;
        if (!up && !down) return <span className="muted">—</span>;
        return (
          <Tag>
            {up ? `↑${up / 1000}` : '↑∞'} / {down ? `↓${down / 1000}` : '↓∞'} Mbps
          </Tag>
        );
      },
    },
    {
      title: t('pages.inbounds.operate'),
      width: 90,
      render: (_, client) => (
        <span className="client-actions">
          <Tooltip title={t('edit')}>
            <Button
              type="text"
              size="small"
              icon={<EditOutlined aria-hidden />}
              aria-label={t('edit')}
              onClick={() => navigate(`/panel/clients?search=${encodeURIComponent(client.email)}`)}
            />
          </Tooltip>
          <Popconfirm
            title={t('pages.inbounds.deleteClientConfirm')}
            okText={t('delete')}
            cancelText={t('cancel')}
            okButtonProps={{ danger: true }}
            onConfirm={() => remove(client)}
          >
            <Button
              danger
              type="text"
              size="small"
              loading={busy === `del:${client.email}`}
              icon={<DeleteOutlined aria-hidden />}
              aria-label={t('delete')}
            />
          </Popconfirm>
        </span>
      ),
    },
  ];

  return (
    <div className="inbound-clients-panel">
      <div className="panel-head">
        <span className="panel-title">
          {t('pages.inbounds.client')} · {clients.length}
        </span>
        <Button
          size="small"
          type="primary"
          icon={<PlusOutlined aria-hidden />}
          onClick={() => setAddOpen(true)}
        >
          {t('pages.clients.addClient')}
        </Button>
      </div>
      <Table
        size="small"
        rowKey="email"
        columns={columns}
        dataSource={clients}
        pagination={clients.length > 10 ? { pageSize: 10, size: 'small' } : false}
        locale={{
          emptyText: <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description={t('noData')} />,
        }}
      />

      <ClientFormModal
        open={addOpen}
        mode="add"
        client={null}
        inbounds={inbounds}
        groups={allGroups}
        tgBotEnable={tgBotEnable}
        save={onSave}
        onOpenChange={setAddOpen}
      />

      <Modal
        open={!!expiryEdit}
        title={t('pages.inbounds.expireDate')}
        onCancel={() => setExpiryEdit(null)}
        onOk={saveExpiry}
        confirmLoading={busy === `expiry:${expiryEdit?.email}`}
        okText={t('save')}
        cancelText={t('cancel')}
        destroyOnHidden
      >
        <DatePicker
          showTime
          aria-label={t('pages.inbounds.expireDate')}
          style={{ width: '100%' }}
          value={expiryEdit?.value ?? null}
          onChange={(v) => setExpiryEdit((prev) => (prev ? { ...prev, value: v } : prev))}
        />
        <Button
          style={{ marginTop: 12 }}
          onClick={() => setExpiryEdit((prev) => (prev ? { ...prev, value: null } : prev))}
        >
          {t('unlimited')}
        </Button>
      </Modal>
    </div>
  );
}
