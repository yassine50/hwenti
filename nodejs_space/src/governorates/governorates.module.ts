import { Module } from '@nestjs/common';
import { GovernoratesController } from './governorates.controller';

@Module({
  controllers: [GovernoratesController],
})
export class GovernoratesModule {}
