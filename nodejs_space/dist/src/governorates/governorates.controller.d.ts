import { PrismaService } from '../prisma/prisma.service';
import { GovernorateListResponseDto, DelegationListResponseDto } from './dto/governorate-response.dto';
export declare class GovernoratesController {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<GovernorateListResponseDto>;
    findDelegations(id: string): Promise<DelegationListResponseDto>;
}
