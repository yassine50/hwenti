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
exports.SuccessResponseDto = exports.ViewCountResponseDto = exports.ProductListResponseDto = exports.ProductListItemDto = exports.ProductDetailResponseDto = exports.ProductMerchantDto = exports.ProductImageDto = exports.UpdateProductDto = exports.CreateProductDto = void 0;
const openapi = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateProductDto {
    name;
    price;
    phone;
    description;
    expiryDate;
    publishDate;
    imageFileIds;
    static _OPENAPI_METADATA_FACTORY() {
        return { name: { required: true, type: () => String }, price: { required: true, type: () => Number, minimum: 0 }, phone: { required: true, type: () => String }, description: { required: false, type: () => String }, expiryDate: { required: true, type: () => String }, publishDate: { required: false, type: () => String }, imageFileIds: { required: true, type: () => [String], minItems: 1, maxItems: 6 } };
    }
}
exports.CreateProductDto = CreateProductDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProductDto.prototype, "name", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], CreateProductDto.prototype, "price", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProductDto.prototype, "phone", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateProductDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsDateString)(),
    __metadata("design:type", String)
], CreateProductDto.prototype, "expiryDate", void 0);
__decorate([
    (0, class_validator_1.IsDateString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateProductDto.prototype, "publishDate", void 0);
__decorate([
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ArrayMinSize)(1),
    (0, class_validator_1.ArrayMaxSize)(6),
    (0, class_validator_1.IsString)({ each: true }),
    __metadata("design:type", Array)
], CreateProductDto.prototype, "imageFileIds", void 0);
class UpdateProductDto {
    name;
    price;
    phone;
    description;
    expiryDate;
    publishDate;
    imageFileIds;
    static _OPENAPI_METADATA_FACTORY() {
        return { name: { required: false, type: () => String }, price: { required: false, type: () => Number, minimum: 0 }, phone: { required: false, type: () => String }, description: { required: false, type: () => String }, expiryDate: { required: false, type: () => String }, publishDate: { required: false, type: () => String }, imageFileIds: { required: false, type: () => [String], minItems: 1, maxItems: 6 } };
    }
}
exports.UpdateProductDto = UpdateProductDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProductDto.prototype, "name", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], UpdateProductDto.prototype, "price", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProductDto.prototype, "phone", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProductDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsDateString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProductDto.prototype, "expiryDate", void 0);
__decorate([
    (0, class_validator_1.IsDateString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProductDto.prototype, "publishDate", void 0);
__decorate([
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ArrayMinSize)(1),
    (0, class_validator_1.ArrayMaxSize)(6),
    (0, class_validator_1.IsString)({ each: true }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Array)
], UpdateProductDto.prototype, "imageFileIds", void 0);
class ProductImageDto {
    id;
    fileId;
    url;
    isPrimary;
    sortOrder;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, fileId: { required: true, type: () => String }, url: { required: true, type: () => String }, isPrimary: { required: true, type: () => Boolean }, sortOrder: { required: true, type: () => Number } };
    }
}
exports.ProductImageDto = ProductImageDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductImageDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductImageDto.prototype, "fileId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductImageDto.prototype, "url", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], ProductImageDto.prototype, "isPrimary", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductImageDto.prototype, "sortOrder", void 0);
class ProductMerchantDto {
    id;
    shopName;
    averageRating;
    logoFileId;
    logoUrl;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, shopName: { required: true, type: () => String, nullable: true }, averageRating: { required: true, type: () => Number }, logoFileId: { required: true, type: () => String, nullable: true }, logoUrl: { required: true, type: () => String, nullable: true } };
    }
}
exports.ProductMerchantDto = ProductMerchantDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductMerchantDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], ProductMerchantDto.prototype, "shopName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductMerchantDto.prototype, "averageRating", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], ProductMerchantDto.prototype, "logoFileId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], ProductMerchantDto.prototype, "logoUrl", void 0);
class ProductDetailResponseDto {
    id;
    name;
    price;
    phone;
    description;
    expiryDate;
    publishDate;
    viewCount;
    isAvailable;
    merchant;
    images;
    isFavorited;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, name: { required: true, type: () => String }, price: { required: true, type: () => Number }, phone: { required: true, type: () => String }, description: { required: true, type: () => String, nullable: true }, expiryDate: { required: true, type: () => String }, publishDate: { required: true, type: () => String }, viewCount: { required: true, type: () => Number }, isAvailable: { required: true, type: () => Boolean }, merchant: { required: true, type: () => require("./product.dto").ProductMerchantDto }, images: { required: true, type: () => [require("./product.dto").ProductImageDto] }, isFavorited: { required: true, type: () => Boolean }, createdAt: { required: true, type: () => String } };
    }
}
exports.ProductDetailResponseDto = ProductDetailResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductDetailResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductDetailResponseDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductDetailResponseDto.prototype, "price", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductDetailResponseDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], ProductDetailResponseDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductDetailResponseDto.prototype, "expiryDate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductDetailResponseDto.prototype, "publishDate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductDetailResponseDto.prototype, "viewCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], ProductDetailResponseDto.prototype, "isAvailable", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => ProductMerchantDto }),
    __metadata("design:type", ProductMerchantDto)
], ProductDetailResponseDto.prototype, "merchant", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [ProductImageDto] }),
    __metadata("design:type", Array)
], ProductDetailResponseDto.prototype, "images", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], ProductDetailResponseDto.prototype, "isFavorited", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductDetailResponseDto.prototype, "createdAt", void 0);
class ProductListItemDto {
    id;
    name;
    price;
    phone;
    description;
    expiryDate;
    publishDate;
    viewCount;
    isAvailable;
    merchant;
    primaryImageUrl;
    imageCount;
    isFavorited;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, name: { required: true, type: () => String }, price: { required: true, type: () => Number }, phone: { required: true, type: () => String }, description: { required: true, type: () => String, nullable: true }, expiryDate: { required: true, type: () => String }, publishDate: { required: true, type: () => String }, viewCount: { required: true, type: () => Number }, isAvailable: { required: true, type: () => Boolean }, merchant: { required: true, type: () => require("./product.dto").ProductMerchantDto }, primaryImageUrl: { required: true, type: () => String, nullable: true }, imageCount: { required: true, type: () => Number }, isFavorited: { required: true, type: () => Boolean }, createdAt: { required: true, type: () => String } };
    }
}
exports.ProductListItemDto = ProductListItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductListItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductListItemDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductListItemDto.prototype, "price", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductListItemDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], ProductListItemDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductListItemDto.prototype, "expiryDate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductListItemDto.prototype, "publishDate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductListItemDto.prototype, "viewCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], ProductListItemDto.prototype, "isAvailable", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => ProductMerchantDto }),
    __metadata("design:type", ProductMerchantDto)
], ProductListItemDto.prototype, "merchant", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], ProductListItemDto.prototype, "primaryImageUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductListItemDto.prototype, "imageCount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], ProductListItemDto.prototype, "isFavorited", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], ProductListItemDto.prototype, "createdAt", void 0);
class ProductListResponseDto {
    items;
    total;
    page;
    totalPages;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./product.dto").ProductListItemDto] }, total: { required: true, type: () => Number }, page: { required: true, type: () => Number }, totalPages: { required: true, type: () => Number } };
    }
}
exports.ProductListResponseDto = ProductListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [ProductListItemDto] }),
    __metadata("design:type", Array)
], ProductListResponseDto.prototype, "items", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductListResponseDto.prototype, "total", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductListResponseDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ProductListResponseDto.prototype, "totalPages", void 0);
class ViewCountResponseDto {
    viewCount;
    static _OPENAPI_METADATA_FACTORY() {
        return { viewCount: { required: true, type: () => Number } };
    }
}
exports.ViewCountResponseDto = ViewCountResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], ViewCountResponseDto.prototype, "viewCount", void 0);
class SuccessResponseDto {
    success;
    static _OPENAPI_METADATA_FACTORY() {
        return { success: { required: true, type: () => Boolean } };
    }
}
exports.SuccessResponseDto = SuccessResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], SuccessResponseDto.prototype, "success", void 0);
//# sourceMappingURL=product.dto.js.map