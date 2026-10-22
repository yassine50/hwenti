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
exports.FollowListResponseDto = exports.FollowItemDto = exports.FollowMerchantDto = exports.FollowSuccessDto = void 0;
const openapi = require("@nestjs/swagger");
const swagger_1 = require("@nestjs/swagger");
class FollowSuccessDto {
    success;
    static _OPENAPI_METADATA_FACTORY() {
        return { success: { required: true, type: () => Boolean } };
    }
}
exports.FollowSuccessDto = FollowSuccessDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], FollowSuccessDto.prototype, "success", void 0);
class FollowMerchantDto {
    id;
    shopName;
    tradeType;
    governorateName;
    governorateNameAr;
    governorateNameFr;
    logoFileId;
    logoUrl;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, shopName: { required: true, type: () => String, nullable: true }, tradeType: { required: true, type: () => String, nullable: true }, governorateName: { required: true, type: () => String, nullable: true }, governorateNameAr: { required: true, type: () => String, nullable: true }, governorateNameFr: { required: true, type: () => String, nullable: true }, logoFileId: { required: true, type: () => String, nullable: true }, logoUrl: { required: true, type: () => String, nullable: true } };
    }
}
exports.FollowMerchantDto = FollowMerchantDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], FollowMerchantDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "shopName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "tradeType", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "governorateName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "governorateNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "governorateNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "logoFileId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], FollowMerchantDto.prototype, "logoUrl", void 0);
class FollowItemDto {
    id;
    merchant;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, merchant: { required: true, type: () => require("./follow.dto").FollowMerchantDto }, createdAt: { required: true, type: () => String } };
    }
}
exports.FollowItemDto = FollowItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], FollowItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => FollowMerchantDto }),
    __metadata("design:type", FollowMerchantDto)
], FollowItemDto.prototype, "merchant", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], FollowItemDto.prototype, "createdAt", void 0);
class FollowListResponseDto {
    items;
    total;
    page;
    totalPages;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./follow.dto").FollowItemDto] }, total: { required: true, type: () => Number }, page: { required: true, type: () => Number }, totalPages: { required: true, type: () => Number } };
    }
}
exports.FollowListResponseDto = FollowListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [FollowItemDto] }),
    __metadata("design:type", Array)
], FollowListResponseDto.prototype, "items", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], FollowListResponseDto.prototype, "total", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], FollowListResponseDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], FollowListResponseDto.prototype, "totalPages", void 0);
//# sourceMappingURL=follow.dto.js.map