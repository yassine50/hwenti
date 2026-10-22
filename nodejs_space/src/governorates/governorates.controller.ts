import { Controller, Get, Param } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { GovernorateListResponseDto, DelegationListResponseDto } from './dto/governorate-response.dto';

@Controller('api/governorates')
export class GovernoratesController {
  constructor(private prisma: PrismaService) {}

  @Get()
  async findAll(): Promise<GovernorateListResponseDto> {
    const items = await this.prisma.governorate.findMany({ orderBy: { nameAr: 'asc' } });
    return { items: items.map(g => ({ id: g.id, name: g.name, nameAr: g.nameAr, nameFr: g.nameFr })) };
  }

  @Get(':id/delegations')
  async findDelegations(@Param('id') id: string): Promise<DelegationListResponseDto> {
    const items = await this.prisma.delegation.findMany({
      where: { governorateId: id },
      orderBy: { nameAr: 'asc' },
    });
    return { items: items.map(d => ({ id: d.id, name: d.name, nameAr: d.nameAr, nameFr: d.nameFr, governorateId: d.governorateId })) };
  }
}
