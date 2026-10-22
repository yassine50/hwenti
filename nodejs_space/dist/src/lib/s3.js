"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generatePresignedUploadUrl = generatePresignedUploadUrl;
exports.getFileUrl = getFileUrl;
exports.deleteFile = deleteFile;
const client_s3_1 = require("@aws-sdk/client-s3");
const s3_request_presigner_1 = require("@aws-sdk/s3-request-presigner");
const aws_config_1 = require("./aws-config");
let _s3 = null;
function getS3() {
    if (!_s3)
        _s3 = (0, aws_config_1.createS3Client)();
    return _s3;
}
function shouldServeInline(contentType) {
    return ((contentType.startsWith('image/') && contentType !== 'image/svg+xml') ||
        contentType.startsWith('video/') ||
        contentType.startsWith('audio/'));
}
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const LOCAL_UPLOAD_DIR = path.join(process.cwd(), 'uploads');
function isLocalMode() {
    return (process.env.DATABASE_URL ?? '').startsWith('file:') && !process.env.AWS_ACCESS_KEY_ID;
}
async function generatePresignedUploadUrl(fileName, contentType, isPublic = false) {
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
    const { bucketName, folderPrefix } = (0, aws_config_1.getBucketConfig)();
    const prefix = isPublic ? `${folderPrefix}public/uploads` : `${folderPrefix}uploads`;
    const cloud_storage_path = `${prefix}/${Date.now()}-${fileName}`;
    const command = new client_s3_1.PutObjectCommand({
        Bucket: bucketName,
        Key: cloud_storage_path,
        ContentType: contentType,
    });
    const uploadUrl = await (0, s3_request_presigner_1.getSignedUrl)(getS3(), command, { expiresIn: 3600 });
    return { uploadUrl, cloud_storage_path };
}
async function getFileUrl(cloud_storage_path, contentType, isPublic) {
    if (cloud_storage_path.startsWith('http://') || cloud_storage_path.startsWith('https://')) {
        return cloud_storage_path;
    }
    if (cloud_storage_path.startsWith('local/')) {
        const fileName = cloud_storage_path.split('/').pop() ?? '';
        const port = process.env.PORT ?? 3333;
        return `http://localhost:${port}/api/uploads/${encodeURIComponent(fileName)}`;
    }
    const { bucketName } = (0, aws_config_1.getBucketConfig)();
    if (isPublic) {
        const region = await getS3().config.region();
        const encodedPath = cloud_storage_path
            .split('/')
            .map(encodeURIComponent)
            .join('/');
        return `https://${bucketName}.s3.${region}.amazonaws.com/${encodedPath}`;
    }
    const disposition = shouldServeInline(contentType) ? 'inline' : 'attachment';
    const command = new client_s3_1.GetObjectCommand({
        Bucket: bucketName,
        Key: cloud_storage_path,
        ResponseContentDisposition: disposition,
    });
    return (0, s3_request_presigner_1.getSignedUrl)(getS3(), command, { expiresIn: 3600 });
}
async function deleteFile(cloud_storage_path) {
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
    const { bucketName } = (0, aws_config_1.getBucketConfig)();
    const command = new client_s3_1.DeleteObjectCommand({
        Bucket: bucketName,
        Key: cloud_storage_path,
    });
    await getS3().send(command);
}
//# sourceMappingURL=s3.js.map