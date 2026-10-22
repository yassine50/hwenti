import {
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { createS3Client, getBucketConfig } from './aws-config';

let _s3: ReturnType<typeof createS3Client> | null = null;
function getS3() {
  if (!_s3) _s3 = createS3Client();
  return _s3;
}

function shouldServeInline(contentType: string): boolean {
  return (
    (contentType.startsWith('image/') && contentType !== 'image/svg+xml') ||
    contentType.startsWith('video/') ||
    contentType.startsWith('audio/')
  );
}

import * as fs from 'fs';
import * as path from 'path';

const LOCAL_UPLOAD_DIR = path.join(process.cwd(), 'uploads');

function isLocalMode(): boolean {
  return (process.env.DATABASE_URL ?? '').startsWith('file:') && !process.env.AWS_ACCESS_KEY_ID;
}

export async function generatePresignedUploadUrl(
  fileName: string,
  contentType: string,
  isPublic = false,
) {
  if (isLocalMode()) {
    if (!fs.existsSync(LOCAL_UPLOAD_DIR)) {
      fs.mkdirSync(LOCAL_UPLOAD_DIR, { recursive: true });
    }
    const safeName = `${Date.now()}-${fileName.replace(/[^a-zA-Z0-9._-]/g, '_')}`;
    const prefix = isPublic ? 'local/public/uploads' : 'local/uploads';
    const cloud_storage_path = `${prefix}/${safeName}`;
    const port = process.env.PORT ?? 3333;
    const uploadUrl = `http://localhost:${port}/api/upload/local/${encodeURIComponent(safeName)}`;
    return { uploadUrl, cloud_storage_path };
  }

  const { bucketName, folderPrefix } = getBucketConfig();
  const prefix = isPublic ? `${folderPrefix}public/uploads` : `${folderPrefix}uploads`;
  const cloud_storage_path = `${prefix}/${Date.now()}-${fileName}`;

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: cloud_storage_path,
    ContentType: contentType,
  });

  const uploadUrl = await getSignedUrl(getS3(), command, { expiresIn: 3600 });
  return { uploadUrl, cloud_storage_path };
}

export async function getFileUrl(
  cloud_storage_path: string,
  contentType: string,
  isPublic: boolean,
) {
  if (cloud_storage_path.startsWith('http://') || cloud_storage_path.startsWith('https://')) {
    return cloud_storage_path;
  }
  if (cloud_storage_path.startsWith('local/')) {
    const fileName = cloud_storage_path.split('/').pop() ?? '';
    const port = process.env.PORT ?? 3333;
    return `http://localhost:${port}/api/uploads/${encodeURIComponent(fileName)}`;
  }

  const { bucketName } = getBucketConfig();
  if (isPublic) {
    const region = await getS3().config.region();
    const encodedPath = cloud_storage_path
      .split('/')
      .map(encodeURIComponent)
      .join('/');
    return `https://${bucketName}.s3.${region}.amazonaws.com/${encodedPath}`;
  }
  const disposition = shouldServeInline(contentType) ? 'inline' : 'attachment';
  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: cloud_storage_path,
    ResponseContentDisposition: disposition,
  });
  return getSignedUrl(getS3(), command, { expiresIn: 3600 });
}

export async function deleteFile(cloud_storage_path: string) {
  if (cloud_storage_path.startsWith('http://') || cloud_storage_path.startsWith('https://')) {
    return;
  }
  if (cloud_storage_path.startsWith('local/')) {
    const fileName = cloud_storage_path.split('/').pop() ?? '';
    const localFile = path.join(LOCAL_UPLOAD_DIR, fileName);
    if (fs.existsSync(localFile)) {
      fs.unlinkSync(localFile);
    }
    return;
  }
  const { bucketName } = getBucketConfig();
  const command = new DeleteObjectCommand({
    Bucket: bucketName,
    Key: cloud_storage_path,
  });
  await getS3().send(command);
}
