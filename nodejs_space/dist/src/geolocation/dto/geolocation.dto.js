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
exports.NearestLocationResponseDto = exports.GeoDelegationDto = exports.GeoGovernorateDto = exports.NearestLocationDto = void 0;
const openapi = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class NearestLocationDto {
    latitude;
    longitude;
    static _OPENAPI_METADATA_FACTORY() {
        return { latitude: { required: true, type: () => Number }, longitude: { required: true, type: () => Number } };
    }
}
exports.NearestLocationDto = NearestLocationDto;
__decorate([
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], NearestLocationDto.prototype, "latitude", void 0);
__decorate([
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], NearestLocationDto.prototype, "longitude", void 0);
class GeoGovernorateDto {
    id;
    name;
    nameAr;
    nameFr;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, name: { required: true, type: () => String }, nameAr: { required: true, type: () => String }, nameFr: { required: true, type: () => String } };
    }
}
exports.GeoGovernorateDto = GeoGovernorateDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoGovernorateDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoGovernorateDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoGovernorateDto.prototype, "nameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoGovernorateDto.prototype, "nameFr", void 0);
class GeoDelegationDto {
    id;
    name;
    nameAr;
    nameFr;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, name: { required: true, type: () => String }, nameAr: { required: true, type: () => String }, nameFr: { required: true, type: () => String } };
    }
}
exports.GeoDelegationDto = GeoDelegationDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoDelegationDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoDelegationDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoDelegationDto.prototype, "nameAr", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], GeoDelegationDto.prototype, "nameFr", void 0);
class NearestLocationResponseDto {
    governorate;
    delegation;
    static _OPENAPI_METADATA_FACTORY() {
        return { governorate: { required: true, type: () => require("./geolocation.dto").GeoGovernorateDto }, delegation: { required: true, type: () => require("./geolocation.dto").GeoDelegationDto, nullable: true } };
    }
}
exports.NearestLocationResponseDto = NearestLocationResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => GeoGovernorateDto }),
    __metadata("design:type", GeoGovernorateDto)
], NearestLocationResponseDto.prototype, "governorate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => GeoDelegationDto, nullable: true }),
    __metadata("design:type", Object)
], NearestLocationResponseDto.prototype, "delegation", void 0);
//# sourceMappingURL=geolocation.dto.js.map