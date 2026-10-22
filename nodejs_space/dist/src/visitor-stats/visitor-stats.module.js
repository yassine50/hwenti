"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.VisitorStatsModule = void 0;
const common_1 = require("@nestjs/common");
const visitor_stats_controller_1 = require("./visitor-stats.controller");
let VisitorStatsModule = class VisitorStatsModule {
};
exports.VisitorStatsModule = VisitorStatsModule;
exports.VisitorStatsModule = VisitorStatsModule = __decorate([
    (0, common_1.Module)({
        controllers: [visitor_stats_controller_1.VisitorStatsController],
    })
], VisitorStatsModule);
//# sourceMappingURL=visitor-stats.module.js.map