import { ApiProperty } from '@nestjs/swagger';

export class FollowSuccessDto {
  @ApiProperty()
  success: boolean;
}

export class FollowMerchantDto {
  @ApiProperty()
  id: string;

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
  logoFileId: string | null;

  @ApiProperty({ nullable: true })
  logoUrl: string | null;
}

export class FollowItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ type: () => FollowMerchantDto })
  merchant: FollowMerchantDto;

  @ApiProperty()
  createdAt: string;
}

export class FollowListResponseDto {
  @ApiProperty({ type: () => [FollowItemDto] })
  items: FollowItemDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  page: number;

  @ApiProperty()
  totalPages: number;
}
