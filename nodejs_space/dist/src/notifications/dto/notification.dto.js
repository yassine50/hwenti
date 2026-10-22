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
exports.NotificationReadResponseDto = exports.NotificationListResponseDto = exports.NotificationItemDto = void 0;
const openapi = require("@nestjs/swagger");
const swagger_1 = require("@nestjs/swagger");
class NotificationItemDto {
    id;
    type;
    message;
    productId;
    merchantId;
    merchantName;
    merchantLogoUrl;
    isRead;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, type: { required: true, type: () => String }, message: { required: true, type: () => String }, productId: { required: true, type: () => String, nullable: true }, merchantId: { required: true, type: () => String }, merchantName: { required: true, type: () => String, nullable: true }, merchantLogoUrl: { required: true, type: () => String, nullable: true }, isRead: { required: true, type: () => Boolean }, createdAt: { required: true, type: () => String } };
    }
}
exports.NotificationItemDto = NotificationItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], NotificationItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], NotificationItemDto.prototype, "type", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], NotificationItemDto.prototype, "message", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], NotificationItemDto.prototype, "productId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], NotificationItemDto.prototype, "merchantId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], NotificationItemDto.prototype, "merchantName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ nullable: true }),
    __metadata("design:type", Object)
], NotificationItemDto.prototype, "merchantLogoUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], NotificationItemDto.prototype, "isRead", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], NotificationItemDto.prototype, "createdAt", void 0);
class NotificationListResponseDto {
    items;
    total;
    page;
    totalPages;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./notification.dto").NotificationItemDto] }, total: { required: true, type: () => Number }, page: { required: true, type: () => Number }, totalPages: { required: true, type: () => Number } };
    }
}
exports.NotificationListResponseDto = NotificationListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [NotificationItemDto] }),
    __metadata("design:type", Array)
], NotificationListResponseDto.prototype, "items", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], NotificationListResponseDto.prototype, "total", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], NotificationListResponseDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], NotificationListResponseDto.prototype, "totalPages", void 0);
class NotificationReadResponseDto {
    success;
    static _OPENAPI_METADATA_FACTORY() {
        return { success: { required: true, type: () => Boolean } };
    }
}
exports.NotificationReadResponseDto = NotificationReadResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], NotificationReadResponseDto.prototype, "success", void 0);
//# sourceMappingURL=notification.dto.js.map