import { useCallback, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Button,
  Card,
  Col,
  Form,
  Input,
  Layout,
  List,
  Row,
  Select,
  Space,
  Spin,
  Tag,
  Typography,
  message,
} from 'antd';
import {
  CheckCircleOutlined,
  CloseCircleOutlined,
  CloudOutlined,
  CopyOutlined,
  ReloadOutlined,
} from '@ant-design/icons';

import { useInboundOptions } from '@/api/queries/useInboundOptions';
import { HttpUtil } from '@/utils';

const { Content } = Layout;
const { Text, Paragraph } = Typography;

interface ArgoConfig {
  quickEnable: boolean;
  quickInboundId: number;
  quickDomain: string;
  namedEnable: boolean;
  namedToken: string;
  namedDomain: string;
  namedInboundId: number;
  cdnAddress: string;
}

interface TunnelStatus {
  kind: string;
  running: boolean;
  domain: string;
  originPort: number;
  err: string;
  restarts: number;
  startedAt: number;
  log: string[];
}

interface ArgoStatus {
  config: ArgoConfig;
  quick: TunnelStatus;
  named: TunnelStatus;
  binaryPath: string;
  version: string;
}

interface ClientLinks {
  email: string;
  links: string[];
}

async function fetchStatus(): Promise<ArgoStatus> {
  const msg = await HttpUtil.get('/panel/api/argo/status', undefined, { silent: true });
  if (!msg?.success) throw new Error(msg?.msg || 'argo status failed');
  return msg.obj as ArgoStatus;
}

function TunnelCard({
  title,
  status,
  domain,
  extra,
  onStart,
  onStop,
}: {
  title: string;
  status: TunnelStatus;
  domain: string;
  extra?: React.ReactNode;
  onStart: () => void;
  onStop: () => void;
}) {
  const { t } = useTranslation();
  return (
    <Card
      title={
        <Space>
          <CloudOutlined aria-hidden />
          {title}
        </Space>
      }
      extra={
        <Space>
          {status.running ? (
            <Tag icon={<CheckCircleOutlined aria-hidden />} color="success">
              {t('pages.argotunnel.running')}
            </Tag>
          ) : (
            <Tag icon={<CloseCircleOutlined aria-hidden />} color="default">
              {t('pages.argotunnel.stopped')}
            </Tag>
          )}
          <Button size="small" type="primary" disabled={status.running} onClick={onStart}>
            {t('pages.argotunnel.start')}
          </Button>
          <Button size="small" danger disabled={!status.running} onClick={onStop}>
            {t('pages.argotunnel.stop')}
          </Button>
        </Space>
      }
    >
      <Space direction="vertical" style={{ width: '100%' }}>
        <Paragraph copyable={domain ? { text: domain } : false} style={{ marginBottom: 0 }}>
          <Text strong>{domain || t('pages.argotunnel.noDomain')}</Text>
        </Paragraph>
        {extra}
        {status.err ? <Alert type="error" showIcon message={status.err} /> : null}
        {status.restarts > 0 ? (
          <Text type="secondary">
            {t('pages.argotunnel.restarts')}: {status.restarts}
          </Text>
        ) : null}
      </Space>
    </Card>
  );
}

export default function ArgoPage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [form] = Form.useForm();
  const [saving, setSaving] = useState(false);
  const [linksInboundId, setLinksInboundId] = useState<number | null>(null);
  const [clientLinks, setClientLinks] = useState<ClientLinks[]>([]);

  const statusQuery = useQuery({
    queryKey: ['argo', 'status'],
    queryFn: fetchStatus,
    refetchInterval: 5000,
  });
  const { data: inboundOptions } = useInboundOptions();

  const status = statusQuery.data;

  useEffect(() => {
    if (status) {
      form.setFieldsValue({
        cdnAddress: status.config.cdnAddress,
        quickInboundId: status.config.quickInboundId || undefined,
        namedDomain: status.config.namedDomain,
        namedToken: status.config.namedToken,
        namedInboundId: status.config.namedInboundId || undefined,
      });
    }
  }, [status, form]);

  const refresh = useCallback(() => {
    queryClient.invalidateQueries({ queryKey: ['argo', 'status'] });
  }, [queryClient]);

  const action = useCallback(
    async (path: string) => {
      const msg = await HttpUtil.post(`/panel/api/argo/${path}`);
      if (msg?.success) {
        message.success(msg.msg);
      }
      refresh();
    },
    [refresh],
  );

  const saveConfig = useCallback(async () => {
    const values = await form.validateFields();
    setSaving(true);
    try {
      const cfg = {
        quickEnable: status?.config.quickEnable ?? false,
        quickInboundId: values.quickInboundId ?? 0,
        quickDomain: status?.config.quickDomain ?? '',
        namedEnable: status?.config.namedEnable ?? false,
        namedToken: values.namedToken ?? '',
        namedDomain: values.namedDomain ?? '',
        namedInboundId: values.namedInboundId ?? 0,
        cdnAddress: values.cdnAddress ?? 'www.visa.com.sg',
      };
      const msg = await HttpUtil.post('/panel/api/argo/config', cfg);
      if (msg?.success) {
        message.success(msg.msg);
      }
      refresh();
    } finally {
      setSaving(false);
    }
  }, [form, status, refresh]);

  const loadLinks = useCallback(async (inboundId: number) => {
    setLinksInboundId(inboundId);
    const msg = await HttpUtil.get(`/panel/api/argo/links/${inboundId}`);
    if (msg?.success) {
      setClientLinks((msg.obj as ClientLinks[]) ?? []);
    }
  }, []);

  const inboundSelectOptions = (inboundOptions ?? []).map((o) => ({
    value: o.id,
    label: `${o.remark || o.tag || o.id} — ${o.protocol ?? ''}:${o.port ?? ''}${
      o.network ? ` (${o.network})` : ''
    }`,
  }));

  return (
    <Layout style={{ minHeight: '100vh', background: 'transparent' }}>
      <Content style={{ padding: 24 }}>
        <Space direction="vertical" size="large" style={{ width: '100%' }}>
          <Typography.Title level={4} style={{ marginTop: 0 }}>
            <CloudOutlined aria-hidden /> {t('pages.argotunnel.title')}
          </Typography.Title>
          <Alert
            type="info"
            showIcon
            message={t('pages.argotunnel.hint')}
            description={t('pages.argotunnel.hintDetail')}
          />

          {statusQuery.isLoading ? (
            <Spin />
          ) : (
            <Row gutter={[16, 16]}>
              <Col xs={24} lg={12}>
                <TunnelCard
                  title={t('pages.argotunnel.quick')}
                  status={status!.quick}
                  domain={status!.config.quickDomain}
                  onStart={() => action('quick/start')}
                  onStop={() => action('quick/stop')}
                  extra={
                    <Text type="secondary">
                      {t('pages.argotunnel.quickDesc')}
                      {status!.version ? ` · cloudflared ${status!.version}` : ''}
                    </Text>
                  }
                />
              </Col>
              <Col xs={24} lg={12}>
                <TunnelCard
                  title={t('pages.argotunnel.named')}
                  status={status!.named}
                  domain={status!.config.namedDomain}
                  onStart={() => action('named/start')}
                  onStop={() => action('named/stop')}
                  extra={<Text type="secondary">{t('pages.argotunnel.namedDesc')}</Text>}
                />
              </Col>
            </Row>
          )}

          <Card title={t('pages.argotunnel.config')}>
            <Form form={form} layout="vertical" onFinish={saveConfig}>
              <Row gutter={[16, 0]}>
                <Col xs={24} md={12}>
                  <Form.Item
                    name="cdnAddress"
                    label={t('pages.argotunnel.cdnAddress')}
                    tooltip={t('pages.argotunnel.cdnAddressTip')}
                  >
                    <Input placeholder="www.visa.com.sg" />
                  </Form.Item>
                  <Form.Item
                    name="quickInboundId"
                    label={t('pages.argotunnel.quickInbound')}
                    tooltip={t('pages.argotunnel.inboundTip')}
                  >
                    <Select
                      allowClear
                      placeholder={t('pages.argotunnel.selectInbound')}
                      options={inboundSelectOptions}
                    />
                  </Form.Item>
                </Col>
                <Col xs={24} md={12}>
                  <Form.Item
                    name="namedToken"
                    label={t('pages.argotunnel.namedToken')}
                    tooltip={t('pages.argotunnel.namedTokenTip')}
                  >
                    <Input.Password placeholder="eyJ..." />
                  </Form.Item>
                  <Form.Item name="namedDomain" label={t('pages.argotunnel.namedDomain')}>
                    <Input placeholder="proxy.example.com" />
                  </Form.Item>
                  <Form.Item name="namedInboundId" label={t('pages.argotunnel.namedInbound')}>
                    <Select
                      allowClear
                      placeholder={t('pages.argotunnel.selectInbound')}
                      options={inboundSelectOptions}
                    />
                  </Form.Item>
                </Col>
              </Row>
              <Space>
                <Button type="primary" htmlType="submit" loading={saving}>
                  {t('pages.argotunnel.save')}
                </Button>
                <Button icon={<ReloadOutlined aria-hidden />} onClick={refresh}>
                  {t('pages.argotunnel.refresh')}
                </Button>
              </Space>
            </Form>
          </Card>

          <Card
            title={t('pages.argotunnel.links')}
            extra={
              <Select
                aria-label={t('pages.argotunnel.selectInbound')}
                style={{ minWidth: 260 }}
                placeholder={t('pages.argotunnel.selectInbound')}
                value={linksInboundId ?? undefined}
                onChange={loadLinks}
                options={inboundSelectOptions}
              />
            }
          >
            {clientLinks.length === 0 ? (
              <Paragraph type="secondary">{t('pages.argotunnel.linksEmpty')}</Paragraph>
            ) : (
              <List
                dataSource={clientLinks}
                renderItem={(item) => (
                  <List.Item>
                    <List.Item.Meta
                      title={item.email}
                      description={
                        <Space direction="vertical" style={{ width: '100%' }}>
                          {item.links.map((link) => (
                            <Paragraph
                              key={link}
                              copyable={{
                                text: link,
                                icon: [<CopyOutlined key="c" aria-hidden />],
                              }}
                              style={{ marginBottom: 0, fontFamily: 'monospace', fontSize: 12 }}
                            >
                              {link}
                            </Paragraph>
                          ))}
                        </Space>
                      }
                    />
                  </List.Item>
                )}
              />
            )}
          </Card>

          {status?.quick.log?.length || status?.named.log?.length ? (
            <Card title={t('pages.argotunnel.logs')}>
              <pre style={{ maxHeight: 260, overflow: 'auto', fontSize: 12, margin: 0 }}>
                {[...(status?.quick.log ?? []), ...(status?.named.log ?? [])].join('\n')}
              </pre>
            </Card>
          ) : null}
        </Space>
      </Content>
    </Layout>
  );
}
