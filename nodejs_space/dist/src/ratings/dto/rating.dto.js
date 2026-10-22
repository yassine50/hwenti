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
exports.RatingListResponseDto = exports.RatingItemDto = exports.RatingResponseDto = exports.CreateRatingDto = void 0;
const openapi = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateRatingDto {
    score;
    static _OPENAPI_METADATA_FACTORY() {
        return { score: { required: true, type: () => Number, minimum: 1, maximum: 5 } };
    }
}
exports.CreateRatingDto = CreateRatingDto;
__decorate([
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(5),
    __metadata("design:type", Number)
], CreateRatingDto.prototype, "score", void 0);
class RatingResponseDto {
    id;
    merchantId;
    score;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, merchantId: { required: true, type: () => String }, score: { required: true, type: () => Number }, createdAt: { required: true, type: () => String } };
    }
}
exports.RatingResponseDto = RatingResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], RatingResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], RatingResponseDto.prototype, "merchantId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], RatingResponseDto.prototype, "score", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], RatingResponseDto.prototype, "createdAt", void 0);
class RatingItemDto {
    id;
    score;
    userName;
    createdAt;
    static _OPENAPI_METADATA_FACTORY() {
        return { id: { required: true, type: () => String }, score: { required: true, type: () => Number }, userName: { required: true, type: () => String }, createdAt: { required: true, type: () => String } };
    }
}
exports.RatingItemDto = RatingItemDto;
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], RatingItemDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], RatingItemDto.prototype, "score", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], RatingItemDto.prototype, "userName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", String)
], RatingItemDto.prototype, "createdAt", void 0);
class RatingListResponseDto {
    items;
    average;
    total;
    static _OPENAPI_METADATA_FACTORY() {
        return { items: { required: true, type: () => [require("./rating.dto").RatingItemDto] }, average: { required: true, type: () => Number }, total: { required: true, type: () => Number } };
    }
}
exports.RatingListResponseDto = RatingListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ type: () => [RatingItemDto] }),
    __metadata("design:type", Array)
], RatingListResponseDto.prototype, "items", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], RatingListResponseDto.prototype, "average", void 0);
__decorate([
    (0, swagger_1.ApiProperty)(),
    __metadata("design:type", Number)
], RatingListResponseDto.prototype, "total", void 0);
//# sourceMappingURL=rating.dto.js.map