// @ts-nocheck
import type { GeoDelegationDto } from './geoDelegationDto';
import type { GeoGovernorateDto } from './geoGovernorateDto';

export interface NearestLocationResponseDto {
  governorate: GeoGovernorateDto;
  /** @nullable */
  delegation: GeoDelegationDto | null;
}
