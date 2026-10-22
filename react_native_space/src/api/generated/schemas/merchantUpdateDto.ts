// @ts-nocheck
import type { MerchantUpdateDtoTradeType } from './merchantUpdateDtoTradeType';

export interface MerchantUpdateDto {
  shopName?: string;
  tradeType?: MerchantUpdateDtoTradeType;
  governorateId?: string;
  delegationId?: string;
  phone?: string;
  logoFileId?: string;
}
