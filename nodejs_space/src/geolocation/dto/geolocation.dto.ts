import { IsNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class NearestLocationDto {
  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;
}

export class GeoGovernorateDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  nameAr: string;

  @ApiProperty()
  nameFr: string;
}

export class GeoDelegationDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  nameAr: string;

  @ApiProperty()
  nameFr: string;
}

export class NearestLocationResponseDto {
  @ApiProperty({ type: () => GeoGovernorateDto })
  governorate: GeoGovernorateDto;

  @ApiProperty({ type: () => GeoDelegationDto, nullable: true })
  delegation: GeoDelegationDto | null;
}
