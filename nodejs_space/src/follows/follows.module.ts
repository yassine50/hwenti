import { Module } from '@nestjs/common';
import { FollowsController } from './follows.controller';
import { MerchantsModule } from '../merchants/merchants.module';

@Module({
  imports: [MerchantsModule],
  controllers: [FollowsController],
})
export class FollowsModule {}
