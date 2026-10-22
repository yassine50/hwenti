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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MerchantsController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const merchants_service_1 = require("./merchants.service");
const merchant_dto_1 = require("./dto/merchant.dto");
let MerchantsController = class MerchantsController {
    merchantsService;
    constructor(merchantsService) {
        this.merchantsService = merchantsService;
    }
    async setup(dto, req) {
        const user = req.user;
        return this.merchantsService.setup(user.id, dto);
    }
    async updateMe(dto, req) {
        const user = req.user;
        return this.merchantsService.updateMe(user.id, dto);
    }
    async findAll(governorateId, delegationId, tradeType, search, page, limit) {
        return this.merchantsService.findAll({ governorateId, delegationId, tradeType, search, page, limit });
    }
    async findMe(req) {
        const user = req.user;
        return this.merchantsService.findMe(user.id);
    }
    async findOne(id) {
        return this.merchantsService.findOne(id);
    }
};
exports.MerchantsController = MerchantsController;
__decorate([
    (0, common_1.Post)('setup'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 201, type: require("./dto/merchant.dto").MerchantResponseDto }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [merchant_dto_1.MerchantSetupDto, Object]),
    __metadata("design:returntype", Promise)
], MerchantsController.prototype, "setup", null);
__decorate([
    (0, common_1.Patch)('me'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 200, type: require("./dto/merchant.dto").MerchantResponseDto }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [merchant_dto_1.MerchantUpdateDto, Object]),
    __metadata("design:returntype", Promise)
], MerchantsController.prototype, "updateMe", null);
__decorate([
    openapi.ApiQuery({ name: "governorateId", required: false }),
    openapi.ApiQuery({ name: "delegationId", required: false }),
    openapi.ApiQuery({ name: "tradeType", required: false }),
    openapi.ApiQuery({ name: "search", required: false }),
    openapi.ApiQuery({ name: "page", required: false }),
    openapi.ApiQuery({ name: "limit", required: false }),
    (0, common_1.Get)(),
    openapi.ApiResponse({ status: 200, type: require("./dto/merchant.dto").MerchantListResponseDto }),
    __param(0, (0, common_1.Query)('governorateId')),
    __param(1, (0, common_1.Query)('delegationId')),
    __param(2, (0, common_1.Query)('tradeType')),
    __param(3, (0, common_1.Query)('search')),
    __param(4, (0, common_1.Query)('page', new common_1.ParseIntPipe({ optional: true }))),
    __param(5, (0, common_1.Query)('limit', new common_1.ParseIntPipe({ optional: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, Number, Number]),
    __metadata("design:returntype", Promise)
], MerchantsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('me'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 200, type: require("./dto/merchant.dto").MerchantResponseDto }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], MerchantsController.prototype, "findMe", null);
__decorate([
    (0, common_1.Get)(':id'),
    openapi.ApiResponse({ status: 200, type: require("./dto/merchant.dto").MerchantResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MerchantsController.prototype, "findOne", null);
exports.MerchantsController = MerchantsController = __decorate([
    (0, common_1.Controller)('api/merchants'),
    __metadata("design:paramtypes", [merchants_service_1.MerchantsService])
], MerchantsController);
//# sourceMappingURL=merchants.controller.js.map