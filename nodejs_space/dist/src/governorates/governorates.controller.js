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
exports.GovernoratesController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let GovernoratesController = class GovernoratesController {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
        const items = await this.prisma.governorate.findMany({ orderBy: { nameAr: 'asc' } });
        return { items: items.map(g => ({ id: g.id, name: g.name, nameAr: g.nameAr, nameFr: g.nameFr })) };
    }
    async findDelegations(id) {
        const items = await this.prisma.delegation.findMany({
            where: { governorateId: id },
            orderBy: { nameAr: 'asc' },
        });
        return { items: items.map(d => ({ id: d.id, name: d.name, nameAr: d.nameAr, nameFr: d.nameFr, governorateId: d.governorateId })) };
    }
};
exports.GovernoratesController = GovernoratesController;
__decorate([
    (0, common_1.Get)(),
    openapi.ApiResponse({ status: 200, type: require("./dto/governorate-response.dto").GovernorateListResponseDto }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], GovernoratesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id/delegations'),
    openapi.ApiResponse({ status: 200, type: require("./dto/governorate-response.dto").DelegationListResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], GovernoratesController.prototype, "findDelegations", null);
exports.GovernoratesController = GovernoratesController = __decorate([
    (0, common_1.Controller)('api/governorates'),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], GovernoratesController);
//# sourceMappingURL=governorates.controller.js.map