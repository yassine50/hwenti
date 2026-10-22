import { IsString, IsOptional, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class MerchantSetupDto {
  @IsString()
  shopName: string;

  @IsIn(['clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other'])
  tradeType: string;

  @IsString()
  governorateId: string;

  @IsString()
  delegationId: string;

  @IsString()
  phone: string;

  @IsString()
  @IsOptional()
  logoFileId?: string;
}

export class MerchantUpdateDto {
  @IsString()
  @IsOptional()
  shopName?: string;

  @IsIn(['clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other'])
  @IsOptional()
  tradeType?: string;

  @IsString()
  @IsOptional()
  governorateId?: string;

  @IsString()
  @IsOptional()
  delegationId?: string;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsOptional()
  logoFileId?: string;
}

export class MerchantResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  userId: string;

  @ApiProperty({ nullable: true })
  shopName: string | null;

  @ApiProperty({ nullable: true })
  tradeType: string | null;

  @ApiProperty({ nullable: true })
  governorateId: string | null;

  @ApiProperty({ nullable: true })
  governorateName: string | null;

  @ApiProperty({ nullable: true })
  governorateNameAr: string | null;

  @ApiProperty({ nullable: true })
  governorateNameFr: string | null;

  @ApiProperty({ nullable: true })
  delegationId: string | null;

  @ApiProperty({ nullable: true })
  delegationName: string | null;

  @ApiProperty({ nullable: true })
  delegationNameAr: string | null;

  @ApiProperty({ nullable: true })
  delegationNameFr: string | null;

  @ApiProperty({ nullable: true })
  phone: string | null;

  @ApiProperty({ nullable: true })
  logoFileId: string | null;

  @ApiProperty({ nullable: true })
  logoUrl: string | null;

  @ApiProperty()
  averageRating: number;

  @ApiProperty()
  ratingCount: number;

  @ApiProperty()
  setupComplete: boolean;

  @ApiProperty()
  createdAt: string;
}

export class MerchantListItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  userId: string;

  @ApiProperty({ nullable: true })
  shopName: string | null;

  @ApiProperty({ nullable: true })
  tradeType: string | null;

  @ApiProperty({ nullable: true })
  governorateName: string | null;

  @ApiProperty({ nullable: true })
  governorateNameAr: string | null;

  @ApiProperty({ nullable: true })
  governorateNameFr: string | null;

  @ApiProperty({ nullable: true })
  delegationName: string | null;

  @ApiProperty({ nullable: true })
  delegationNameAr: string | null;

  @ApiProperty({ nullable: true })
  delegationNameFr: string | null;

  @ApiProperty({ nullable: true })
  logoFileId: string | null;

  @ApiProperty({ nullable: true })
  logoUrl: string | null;

  @ApiProperty()
  averageRating: number;

  @ApiProperty()
  ratingCount: number;
}

export class MerchantListResponseDto {
  @ApiProperty({ type: () => [MerchantListItemDto] })
  items: MerchantListItemDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  page: number;

  @ApiProperty()
  totalPages: number;
}
