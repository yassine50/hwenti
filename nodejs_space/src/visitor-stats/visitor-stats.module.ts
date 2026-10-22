import { Module } from '@nestjs/common';
import { VisitorStatsController } from './visitor-stats.controller';

@Module({
  controllers: [VisitorStatsController],
})
export class VisitorStatsModule {}
