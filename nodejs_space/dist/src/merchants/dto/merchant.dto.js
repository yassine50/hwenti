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
exports.MerchantListResponseDto = exports.MerchantListItemDto = exports.MerchantResponseDto = exports.MerchantUpdateDto = exports.MerchantSetupDto = void 0;
const openapi = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class MerchantSetupDto {
    shopName;
    tradeType;
    governorateId;
    delegationId;
    phone;
    logoFileId;
    static _OPENAPI_METADATA_FACTORY() {
        return { shopName: { required: true, type: () => String }, tradeType: { required: true, type: () => String, enum: ['clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other'] }, governorateId: { required: true, type: () => String }, delegationId: { required: true, type: () => String }, phone: { required: true, type: () => String }, logoFileId: { required: false, type: () => String } };
    }
}
exports.MerchantSetupDto = MerchantSetupDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], MerchantSetupDto.prototype, "shopName", void 0);
__decorate([
    (0, class_validator_1.IsIn)(['clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other']),
    __metadata("design:type", String)
], MerchantSetupDto.prototype, "tradeType", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], MerchantSetupDto.prototype, "governorateId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], MerchantSetupDto.prototype, "delegationId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], MerchantSetupDto.prototype, "phone", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantSetupDto.prototype, "logoFileId", void 0);
class MerchantUpdateDto {
    shopName;
    tradeType;
    governorateId;
    delegationId;
    phone;
    logoFileId;
    static _OPENAPI_METADATA_FACTORY() {
        return { shopName: { required: false, type: () => String }, tradeType: { required: false, type: () => String, enum: ['clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other'] }, governorateId: { required: false, type: () => String }, delegationId: { required: false, type: () => String }, phone: { required: false, type: () => String }, logoFileId: { required: false, type: () => String } };
    }
}
exports.MerchantUpdateDto = MerchantUpdateDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantUpdateDto.prototype, "shopName", void 0);
__decorate([
    (0, class_validator_1.IsIn)(['clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other']),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantUpdateDto.prototype, "tradeType", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantUpdateDto.prototype, "governorateId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantUpdateDto.prototype, "delegationId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantUpdateDto.prototype, "phone", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], MerchantUpdateDto.prototype, "logoFileId", void 0);
class MerchantResponseDto {
    id;
    userId;
    shopName;
    tradeType;
    governorateId;
    governorateName;
    governorateNameAr;
    governorateNameFr;
    delegationId;
    delegationName;
    delegationNameAr;
    delegationNameFr;
    phone;
    logoFileId;
    logoUrl;
    averageRating;
    ratingCount;
    setupComplete;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, userId: { required: true, type: () => String }, shopName: { required: true, type: () => String, nullable: true }, tradeType: { required: true, type: () => String, nullable: true }, governorateId: { required: true, type: () => String, nullable: true }, governorateName: { required: true, type: () => String, nullable: true }, governorateNameAr: { required: true, type: () => String, nullable: true }, governorateNameFr: { required: true, type: () => String, nullable: true }, delegationId: { required: true, type: () => String, nullable: true }, delegationName: { required: true, type: () => String, nullable: true }, delegationNameAr: { required: true, type: () => String, nullable: true }, delegationNameFr: { required: true, type: () => String, nullable: true }, phone: { required: true, type: () => String, nullable: true }, logoFileId: { required: true, type: () => String, nullable: true }, logoUrl: { required: true, type: () => String, nullable: true }, averageRating: { required: true, type: () => Number }, ratingCount: { required: true, type: () => Number }, setupComplete: { required: true, type: () => Boolean }, createdAt: { required: true, type: () => String } };
    }
}
exports.MerchantResponseDto = MerchantResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], MerchantResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], MerchantResponseDto.prototype, "userId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "shopName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "tradeType", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "governorateId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "governorateName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "governorateNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "governorateNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "delegationId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "delegationName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "delegationNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "delegationNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "logoFileId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantResponseDto.prototype, "logoUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantResponseDto.prototype, "averageRating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantResponseDto.prototype, "ratingCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], MerchantResponseDto.prototype, "setupComplete", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], MerchantResponseDto.prototype, "createdAt", void 0);
class MerchantListItemDto {
    id;
    userId;
    shopName;
    tradeType;
    governorateName;
    governorateNameAr;
    governorateNameFr;
    delegationName;
    delegationNameAr;
    delegationNameFr;
    logoFileId;
    logoUrl;
    averageRating;
    ratingCount;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, userId: { required: true, type: () => String }, shopName: { required: true, type: () => String, nullable: true }, tradeType: { required: true, type: () => String, nullable: true }, governorateName: { required: true, type: () => String, nullable: true }, governorateNameAr: { required: true, type: () => String, nullable: true }, governorateNameFr: { required: true, type: () => String, nullable: true }, delegationName: { required: true, type: () => String, nullable: true }, delegationNameAr: { required: true, type: () => String, nullable: true }, delegationNameFr: { required: true, type: () => String, nullable: true }, logoFileId: { required: true, type: () => String, nullable: true }, logoUrl: { required: true, type: () => String, nullable: true }, averageRating: { required: true, type: () => Number }, ratingCount: { required: true, type: () => Number } };
    }
}
exports.MerchantListItemDto = MerchantListItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], MerchantListItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], MerchantListItemDto.prototype, "userId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "shopName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "tradeType", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "governorateName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "governorateNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "governorateNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "delegationName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "delegationNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "delegationNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "logoFileId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], MerchantListItemDto.prototype, "logoUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantListItemDto.prototype, "averageRating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantListItemDto.prototype, "ratingCount", void 0);
class MerchantListResponseDto {
    items;
    total;
    page;
    totalPages;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./merchant.dto").MerchantListItemDto] }, total: { required: true, type: () => Number }, page: { required: true, type: () => Number }, totalPages: { required: true, type: () => Number } };
    }
}
exports.MerchantListResponseDto = MerchantListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [MerchantListItemDto] }),
    __metadata("design:type", Array)
], MerchantListResponseDto.prototype, "items", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantListResponseDto.prototype, "total", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantListResponseDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], MerchantListResponseDto.prototype, "totalPages", void 0);
//# sourceMappingURL=merchant.dto.js.map