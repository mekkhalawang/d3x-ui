import { useCallback, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Alert,
  Button,
  Form,
  Input,
  InputNumber,
  Modal,
  Radio,
  Space,
  Typography,
  message,
} from 'antd';
import { CloudOutlined, CopyOutlined } from '@ant-design/icons';

import { HttpUtil } from '@/utils';

const { Paragraph, Text } = Typography;

interface ArgoCreateNodeResult {
  inboundId: number;
  remark: string;
  port: number;
  email: string;
  uuid: string;
  wsPath: string;
  mode: string;
  domain: string;
  links: string[];
}

interface Props {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onCreated: () => void;
}

interface FormValues {
  mode: 'quick' | 'named';
  domain?: string;
  token?: string;
  port?: number;
}

export default function ArgoNodeModal({ open, onOpenChange, onCreated }: Props) {
  const { t } = useTranslation();
  const [form] = Form.useForm<FormValues>();
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<ArgoCreateNodeResult | null>(null);
  const mode = Form.useWatch('mode', form) ?? 'quick';

  const submit = useCallback(async () => {
    const values = await form.validateFields();
    setSubmitting(true);
    try {
      const msg = await HttpUtil.post('/panel/api/argo/createNode', {
        mode: values.mode,
        domain: values.domain ?? '',
        token: values.token ?? '',
        port: values.port ?? 0,
      });
      if (msg?.success) {
        message.success(msg.msg);
        setResult(msg.obj as ArgoCreateNodeResult);
        onCreated();
      }
    } finally {
      setSubmitting(false);
    }
  }, [form, onCreated]);

  const close = useCallback(() => {
    setResult(null);
    form.resetFields();
    onOpenChange(false);
  }, [form, onOpenChange]);

  return (
    <Modal
      open={open}
      title={
        <Space>
          <CloudOutlined aria-hidden />
          {t('pages.argotunnel.createNode.title')}
        </Space>
      }
      onCancel={close}
      width={640}
      centered
      footer={
        result ? (
          <Button type="primary" onClick={close}>
            {t('pages.argotunnel.createNode.done')}
          </Button>
        ) : (
          <Space>
            <Button onClick={close}>{t('pages.argotunnel.createNode.cancel')}</Button>
            <Button type="primary" loading={submitting} onClick={submit}>
              {t('pages.argotunnel.createNode.submit')}
            </Button>
          </Space>
        )
      }
    >
      {result ? (
        <Space direction="vertical" style={{ width: '100%' }}>
          <Alert
            type="success"
            showIcon
            message={t('pages.argotunnel.createNode.created')}
            description={`${result.remark} · ${t('pages.argotunnel.createNode.originPort')} ${result.port}${
              result.domain ? ` · ${result.domain}` : ''
            }`}
          />
          <Paragraph copyable={{ text: result.uuid }} style={{ marginBottom: 0 }}>
            <Text type="secondary">UUID: </Text>
            <Text code>{result.uuid}</Text>
          </Paragraph>
          {(result.links ?? []).map((link) => (
            <Paragraph
              key={link}
              copyable={{ text: link, icon: [<CopyOutlined key="c" aria-hidden />] }}
              style={{ marginBottom: 0, fontFamily: 'monospace', fontSize: 12 }}
            >
              {link}
            </Paragraph>
          ))}
          {result.mode === 'quick' && !result.domain ? (
            <Alert
              type="info"
              showIcon
              message={t('pages.argotunnel.createNode.quickDomainHint')}
            />
          ) : null}
        </Space>
      ) : (
        <Form form={form} layout="vertical" initialValues={{ mode: 'quick' }}>
          <Form.Item name="mode" label={t('pages.argotunnel.createNode.mode')}>
            <Radio.Group
              options={[
                { value: 'quick', label: t('pages.argotunnel.createNode.quickOption') },
                { value: 'named', label: t('pages.argotunnel.createNode.namedOption') },
              ]}
            />
          </Form.Item>
          {mode === 'named' ? (
            <>
              <Form.Item
                name="domain"
                label={t('pages.argotunnel.namedDomain')}
                rules={[
                  { required: true, message: t('pages.argotunnel.createNode.domainRequired') },
                ]}
              >
                <Input placeholder="tunnel.example.com" />
              </Form.Item>
              <Form.Item
                name="token"
                label={t('pages.argotunnel.namedToken')}
                tooltip={t('pages.argotunnel.namedTokenTip')}
                rules={[
                  { required: true, message: t('pages.argotunnel.createNode.tokenRequired') },
                ]}
              >
                <Input.Password placeholder="eyJ..." />
              </Form.Item>
            </>
          ) : (
            <Alert
              type="info"
              showIcon
              message={t('pages.argotunnel.createNode.quickOption')}
              description={t('pages.argotunnel.createNode.quickDesc')}
            />
          )}
          <Form.Item
            name="port"
            label={t('pages.argotunnel.createNode.originPort')}
            tooltip={t('pages.argotunnel.createNode.portTip')}
          >
            <InputNumber
              min={1}
              max={65535}
              style={{ width: '100%' }}
              placeholder={t('pages.argotunnel.createNode.portPlaceholder')}
            />
          </Form.Item>
          <Alert type="info" showIcon message={t('pages.argotunnel.createNode.note')} />
        </Form>
      )}
    </Modal>
  );
}
