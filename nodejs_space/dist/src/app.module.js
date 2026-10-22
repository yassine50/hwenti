"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const prisma_module_1 = require("./prisma/prisma.module");
const auth_module_1 = require("./auth/auth.module");
const governorates_module_1 = require("./governorates/governorates.module");
const upload_module_1 = require("./upload/upload.module");
const merchants_module_1 = require("./merchants/merchants.module");
const products_module_1 = require("./products/products.module");
const favorites_module_1 = require("./favorites/favorites.module");
const follows_module_1 = require("./follows/follows.module");
const notifications_module_1 = require("./notifications/notifications.module");
const ratings_module_1 = require("./ratings/ratings.module");
const reports_module_1 = require("./reports/reports.module");
const geolocation_module_1 = require("./geolocation/geolocation.module");
const visitor_stats_module_1 = require("./visitor-stats/visitor-stats.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            prisma_module_1.PrismaModule,
            auth_module_1.AuthModule,
            governorates_module_1.GovernoratesModule,
            upload_module_1.UploadModule,
            merchants_module_1.MerchantsModule,
            products_module_1.ProductsModule,
            favorites_module_1.FavoritesModule,
            follows_module_1.FollowsModule,
            notifications_module_1.NotificationsModule,
            ratings_module_1.RatingsModule,
            reports_module_1.ReportsModule,
            geolocation_module_1.GeolocationModule,
            visitor_stats_module_1.VisitorStatsModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map