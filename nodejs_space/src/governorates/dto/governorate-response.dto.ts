import { ApiProperty } from '@nestjs/swagger';

export class GovernorateItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  nameAr: string;

  @ApiProperty()
  nameFr: string;
}

export class GovernorateListResponseDto {
  @ApiProperty({ type: () => [GovernorateItemDto] })
  items: GovernorateItemDto[];
}

export class DelegationItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  nameAr: string;

  @ApiProperty()
  nameFr: string;

  @ApiProperty()
  governorateId: string;
}

export class DelegationListResponseDto {
  @ApiProperty({ type: () => [DelegationItemDto] })
  items: DelegationItemDto[];
}
