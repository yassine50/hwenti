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
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UploadController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
const s3_1 = require("../lib/s3");
const upload_dto_1 = require("./dto/upload.dto");
let UploadController = class UploadController {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async presigned(dto) {
        const { uploadUrl, cloud_storage_path } = await (0, s3_1.generatePresignedUploadUrl)(dto.fileName, dto.contentType, dto.isPublic ?? true);
        return { uploadUrl, cloud_storage_path };
    }
    async uploadLocal(fileName, req) {
        const uploadDir = path.join(process.cwd(), 'uploads');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        const safeName = path.basename(fileName);
        const targetPath = path.join(uploadDir, safeName);
        const chunks = [];
        for await (const chunk of req) {
            chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
        }
        fs.writeFileSync(targetPath, Buffer.concat(chunks));
        return { ok: true };
    }
    async serveLocal(fileName, res) {
        const safeName = path.basename(fileName);
        const targetPath = path.join(process.cwd(), 'uploads', safeName);
        if (!fs.existsSync(targetPath)) {
            throw new common_1.NotFoundException('File not found');
        }
        return res.sendFile(targetPath);
    }
    async complete(dto, req) {
        const user = req.user;
        const file = await this.prisma.file.create({
            data: {
                userId: user.id,
                fileName: dto.fileName,
                cloud_storage_path: dto.cloud_storage_path,
                isPublic: dto.cloud_storage_path.includes('/public/'),
                contentType: dto.contentType,
                fileSize: dto.fileSize ?? null,
            },
        });
        return { id: file.id, cloud_storage_path: file.cloud_storage_path, fileName: file.fileName };
    }
    async getUrl(id, mode) {
        const file = await this.prisma.file.findUnique({ where: { id } });
        if (!file)
            throw new common_1.NotFoundException('File not found');
        const url = await (0, s3_1.getFileUrl)(file.cloud_storage_path, file.contentType, file.isPublic);
        return { url };
    }
    async deleteFileRecord(id, req) {
        const user = req.user;
        const file = await this.prisma.file.findUnique({ where: { id } });
        if (!file)
            throw new common_1.NotFoundException('File not found');
        if (file.userId !== user.id)
            throw new common_1.ForbiddenException('Unauthorized');
        await (0, s3_1.deleteFile)(file.cloud_storage_path);
        await this.prisma.file.delete({ where: { id } });
        return { success: true };
    }
};
exports.UploadController = UploadController;
__decorate([
    (0, common_1.Post)('upload/presigned'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 201, type: require("./dto/upload.dto").PresignedUploadResponseDto }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [upload_dto_1.PresignedUploadDto]),
    __metadata("design:returntype", Promise)
], UploadController.prototype, "presigned", null);
__decorate([
    (0, common_1.Put)('upload/local/:fileName'),
    openapi.ApiResponse({ status: 200 }),
    __param(0, (0, common_1.Param)('fileName')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], UploadController.prototype, "uploadLocal", null);
__decorate([
    (0, common_1.Get)('uploads/:fileName'),
    openapi.ApiResponse({ status: 200 }),
    __param(0, (0, common_1.Param)('fileName')),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], UploadController.prototype, "serveLocal", null);
__decorate([
    (0, common_1.Post)('upload/complete'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 201, type: require("./dto/upload.dto").CompleteUploadResponseDto }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [upload_dto_1.CompleteUploadDto, Object]),
    __metadata("design:returntype", Promise)
], UploadController.prototype, "complete", null);
__decorate([
    openapi.ApiQuery({ name: "mode", required: false }),
    (0, common_1.Get)('files/:id/url'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 200, type: require("./dto/upload.dto").FileUrlResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('mode')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], UploadController.prototype, "getUrl", null);
__decorate([
    (0, common_1.Delete)('files/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 200, type: require("./dto/upload.dto").DeleteFileResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], UploadController.prototype, "deleteFileRecord", null);
exports.UploadController = UploadController = __decorate([
    (0, common_1.Controller)('api'),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UploadController);
//# sourceMappingURL=upload.controller.js.map