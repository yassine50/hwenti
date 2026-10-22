// @ts-nocheck
import type { CreateReportDtoReason } from './createReportDtoReason';

export interface CreateReportDto {
  merchantId: string;
  reason: CreateReportDtoReason;
  details?: string;
}
