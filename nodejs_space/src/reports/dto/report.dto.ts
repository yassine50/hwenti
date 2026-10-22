import { IsString, IsOptional, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateReportDto {
  @IsString()
  merchantId: string;

  @IsIn(['counterfeit', 'fraud', 'inappropriate', 'other'])
  reason: string;

  @IsString()
  @IsOptional()
  details?: string;
}

export class ReportResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  merchantId: string;

  @ApiProperty()
  reason: string;

  @ApiProperty()
  createdAt: string;
}
