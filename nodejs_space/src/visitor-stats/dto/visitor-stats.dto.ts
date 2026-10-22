import { IsString, IsOptional, IsNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class TrackVisitorDto {
  @IsString()
  @IsOptional()
  governorateId?: string;

  @IsString()
  @IsOptional()
  delegationId?: string;

  @IsNumber()
  @IsOptional()
  latitude?: number;

  @IsNumber()
  @IsOptional()
  longitude?: number;
}

export class TrackVisitorResponseDto {
  @ApiProperty()
  success: boolean;
}

export class GovStatDto {
  @ApiProperty()
  governorateId: string;

  @ApiProperty()
  governorateName: string;

  @ApiProperty()
  governorateNameAr: string;

  @ApiProperty()
  governorateNameFr: string;

  @ApiProperty()
  count: number;
}

export class DelStatDto {
  @ApiProperty()
  delegationId: string;

  @ApiProperty()
  delegationName: string;

  @ApiProperty()
  delegationNameAr: string;

  @ApiProperty()
  delegationNameFr: string;

  @ApiProperty()
  governorateId: string;

  @ApiProperty()
  count: number;
}

export class VisitorStatsSummaryResponseDto {
  @ApiProperty()
  totalVisitors: number;

  @ApiProperty({ type: () => [GovStatDto] })
  byGovernorate: GovStatDto[];

  @ApiProperty({ type: () => [DelStatDto] })
  byDelegation: DelStatDto[];
}
