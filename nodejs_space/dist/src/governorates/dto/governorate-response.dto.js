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
exports.DelegationListResponseDto = exports.DelegationItemDto = exports.GovernorateListResponseDto = exports.GovernorateItemDto = void 0;
const openapi = require("@nestjs/swagger");
const swagger_1 = require("@nestjs/swagger");
class GovernorateItemDto {
    id;
    name;
    nameAr;
    nameFr;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, name: { required: true, type: () => String }, nameAr: { required: true, type: () => String }, nameFr: { required: true, type: () => String } };
    }
}
exports.GovernorateItemDto = GovernorateItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovernorateItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovernorateItemDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovernorateItemDto.prototype, "nameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovernorateItemDto.prototype, "nameFr", void 0);
class GovernorateListResponseDto {
    items;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./governorate-response.dto").GovernorateItemDto] } };
    }
}
exports.GovernorateListResponseDto = GovernorateListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [GovernorateItemDto] }),
    __metadata("design:type", Array)
], GovernorateListResponseDto.prototype, "items", void 0);
class DelegationItemDto {
    id;
    name;
    nameAr;
    nameFr;
    governorateId;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, name: { required: true, type: () => String }, nameAr: { required: true, type: () => String }, nameFr: { required: true, type: () => String }, governorateId: { required: true, type: () => String } };
    }
}
exports.DelegationItemDto = DelegationItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelegationItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelegationItemDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelegationItemDto.prototype, "nameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelegationItemDto.prototype, "nameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelegationItemDto.prototype, "governorateId", void 0);
class DelegationListResponseDto {
    items;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./governorate-response.dto").DelegationItemDto] } };
    }
}
exports.DelegationListResponseDto = DelegationListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [DelegationItemDto] }),
    __metadata("design:type", Array)
], DelegationListResponseDto.prototype, "items", void 0);
//# sourceMappingURL=governorate-response.dto.js.map