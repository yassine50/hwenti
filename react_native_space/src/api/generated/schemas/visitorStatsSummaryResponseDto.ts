// @ts-nocheck
import type { DelStatDto } from './delStatDto';
import type { GovStatDto } from './govStatDto';

export interface VisitorStatsSummaryResponseDto {
  totalVisitors: number;
  byGovernorate: GovStatDto[];
  byDelegation: DelStatDto[];
}
