"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DeleteFileResponseDto = exports.FileUrlResponseDto = exports.CompleteUploadResponseDto = exports.PresignedUploadResponseDto = exports.CompleteUploadDto = exports.PresignedUploadDto = void 0;
const openapi = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class PresignedUploadDto {
    fileName;
    contentType;
    isPublic;
    static _OPENAPI_METADATA_FACTORY() {
        return { fileName: { required: true, type: () => String }, contentType: { required: true, type: () => String }, isPublic: { required: false, type: () => Boolean } };
    }
}
exports.PresignedUploadDto = PresignedUploadDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], PresignedUploadDto.prototype, "fileName", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], PresignedUploadDto.prototype, "contentType", void 0);
__decorate([
    (0, class_validator_1.IsBoolean)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], PresignedUploadDto.prototype, "isPublic", void 0);
class CompleteUploadDto {
    cloud_storage_path;
    fileName;
    contentType;
    fileSize;
    static _OPENAPI_METADATA_FACTORY() {
        return { cloud_storage_path: { required: true, type: () => String }, fileName: { required: true, type: () => String }, contentType: { required: true, type: () => String }, fileSize: { required: false, type: () => Number } };
    }
}
exports.CompleteUploadDto = CompleteUploadDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CompleteUploadDto.prototype, "cloud_storage_path", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CompleteUploadDto.prototype, "fileName", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CompleteUploadDto.prototype, "contentType", void 0);
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CompleteUploadDto.prototype, "fileSize", void 0);
class PresignedUploadResponseDto {
    uploadUrl;
    cloud_storage_path;
    static _OPENAPI_METADATA_FACTORY() {
        return { uploadUrl: { required: true, type: () => String }, cloud_storage_path: { required: true, type: () => String } };
    }
}
exports.PresignedUploadResponseDto = PresignedUploadResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PresignedUploadResponseDto.prototype, "uploadUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], PresignedUploadResponseDto.prototype, "cloud_storage_path", void 0);
class CompleteUploadResponseDto {
    id;
    cloud_storage_path;
    fileName;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, cloud_storage_path: { required: true, type: () => String }, fileName: { required: true, type: () => String } };
    }
}
exports.CompleteUploadResponseDto = CompleteUploadResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], CompleteUploadResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], CompleteUploadResponseDto.prototype, "cloud_storage_path", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], CompleteUploadResponseDto.prototype, "fileName", void 0);
class FileUrlResponseDto {
    url;
    static _OPENAPI_METADATA_FACTORY() {
        return { url: { required: true, type: () => String } };
    }
}
exports.FileUrlResponseDto = FileUrlResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], FileUrlResponseDto.prototype, "url", void 0);
class DeleteFileResponseDto {
    success;
    static _OPENAPI_METADATA_FACTORY() {
        return { success: { required: true, type: () => Boolean } };
    }
}
exports.DeleteFileResponseDto = DeleteFileResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], DeleteFileResponseDto.prototype, "success", void 0);
//# sourceMappingURL=upload.dto.js.map