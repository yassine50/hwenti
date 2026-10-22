import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { GovernoratesModule } from './governorates/governorates.module';
import { UploadModule } from './upload/upload.module';
import { MerchantsModule } from './merchants/merchants.module';
import { ProductsModule } from './products/products.module';
import { FavoritesModule } from './favorites/favorites.module';
import { FollowsModule } from './follows/follows.module';
import { NotificationsModule } from './notifications/notifications.module';
import { RatingsModule } from './ratings/ratings.module';
import { ReportsModule } from './reports/reports.module';
import { GeolocationModule } from './geolocation/geolocation.module';
import { VisitorStatsModule } from './visitor-stats/visitor-stats.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    GovernoratesModule,
    UploadModule,
    MerchantsModule,
    ProductsModule,
    FavoritesModule,
    FollowsModule,
    NotificationsModule,
    RatingsModule,
    ReportsModule,
    GeolocationModule,
    VisitorStatsModule,
  ],
})
export class AppModule {}
