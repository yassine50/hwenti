import type { Request } from 'express';
import { MerchantsService } from './merchants.service';
import { MerchantSetupDto, MerchantUpdateDto, MerchantResponseDto, MerchantListResponseDto } from './dto/merchant.dto';
export declare class MerchantsController {
    private merchantsService;
    constructor(merchantsService: MerchantsService);
    setup(dto: MerchantSetupDto, req: Request): Promise<MerchantResponseDto>;
    updateMe(dto: MerchantUpdateDto, req: Request): Promise<MerchantResponseDto>;
    findAll(governorateId?: string, delegationId?: string, tradeType?: string, search?: string, page?: number, limit?: number): Promise<MerchantListResponseDto>;
    findMe(req: Request): Promise<MerchantResponseDto>;
    findOne(id: string): Promise<MerchantResponseDto>;
}
