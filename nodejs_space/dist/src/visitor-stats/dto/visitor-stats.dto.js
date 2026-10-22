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
exports.VisitorStatsSummaryResponseDto = exports.DelStatDto = exports.GovStatDto = exports.TrackVisitorResponseDto = exports.TrackVisitorDto = void 0;
const openapi = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class TrackVisitorDto {
    governorateId;
    delegationId;
    latitude;
    longitude;
    static _OPENAPI_METADATA_FACTORY() {
        return { governorateId: { required: false, type: () => String }, delegationId: { required: false, type: () => String }, latitude: { required: false, type: () => Number }, longitude: { required: false, type: () => Number } };
    }
}
exports.TrackVisitorDto = TrackVisitorDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], TrackVisitorDto.prototype, "governorateId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], TrackVisitorDto.prototype, "delegationId", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], TrackVisitorDto.prototype, "latitude", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], TrackVisitorDto.prototype, "longitude", void 0);
class TrackVisitorResponseDto {
    success;
    static _OPENAPI_METADATA_FACTORY() {
        return { success: { required: true, type: () => Boolean } };
    }
}
exports.TrackVisitorResponseDto = TrackVisitorResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Boolean)
], TrackVisitorResponseDto.prototype, "success", void 0);
class GovStatDto {
    governorateId;
    governorateName;
    governorateNameAr;
    governorateNameFr;
    count;
    static _OPENAPI_METADATA_FACTORY() {
        return { governorateId: { required: true, type: () => String }, governorateName: { required: true, type: () => String }, governorateNameAr: { required: true, type: () => String }, governorateNameFr: { required: true, type: () => String }, count: { required: true, type: () => Number } };
    }
}
exports.GovStatDto = GovStatDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovStatDto.prototype, "governorateId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovStatDto.prototype, "governorateName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovStatDto.prototype, "governorateNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GovStatDto.prototype, "governorateNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], GovStatDto.prototype, "count", void 0);
class DelStatDto {
    delegationId;
    delegationName;
    delegationNameAr;
    delegationNameFr;
    governorateId;
    count;
    static _OPENAPI_METADATA_FACTORY() {
        return { delegationId: { required: true, type: () => String }, delegationName: { required: true, type: () => String }, delegationNameAr: { required: true, type: () => String }, delegationNameFr: { required: true, type: () => String }, governorateId: { required: true, type: () => String }, count: { required: true, type: () => Number } };
    }
}
exports.DelStatDto = DelStatDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelStatDto.prototype, "delegationId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelStatDto.prototype, "delegationName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelStatDto.prototype, "delegationNameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelStatDto.prototype, "delegationNameFr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], DelStatDto.prototype, "governorateId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], DelStatDto.prototype, "count", void 0);
class VisitorStatsSummaryResponseDto {
    totalVisitors;
    byGovernorate;
    byDelegation;
    static _OPENAPI_METADATA_FACTORY() {
        return { totalVisitors: { required: true, type: () => Number }, byGovernorate: { required: true, type: () => [require("./visitor-stats.dto").GovStatDto] }, byDelegation: { required: true, type: () => [require("./visitor-stats.dto").DelStatDto] } };
    }
}
exports.VisitorStatsSummaryResponseDto = VisitorStatsSummaryResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], VisitorStatsSummaryResponseDto.prototype, "totalVisitors", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [GovStatDto] }),
    __metadata("design:type", Array)
], VisitorStatsSummaryResponseDto.prototype, "byGovernorate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [DelStatDto] }),
    __metadata("design:type", Array)
], VisitorStatsSummaryResponseDto.prototype, "byDelegation", void 0);
//# sourceMappingURL=visitor-stats.dto.js.map