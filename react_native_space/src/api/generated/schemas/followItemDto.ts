// @ts-nocheck
import type { FollowMerchantDto } from './followMerchantDto';

export interface FollowItemDto {
  id: string;
  merchant: FollowMerchantDto;
  createdAt: string;
}
