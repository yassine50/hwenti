import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { TrackVisitorDto, TrackVisitorResponseDto, VisitorStatsSummaryResponseDto } from './dto/visitor-stats.dto';

@Controller('api/visitor-stats')
export class VisitorStatsController {
  constructor(private prisma: PrismaService) {}

  @Post('track')
  async track(@Body() dto: TrackVisitorDto): Promise<TrackVisitorResponseDto> {
    await this.prisma.visitorStat.create({
      data: {
        governorateId: dto.governorateId ?? null,
        delegationId: dto.delegationId ?? null,
        latitude: dto.latitude ?? null,
        longitude: dto.longitude ?? null,
      },
    });
    return { success: true };
  }

  @Get('summary')
  @UseGuards(JwtAuthGuard)
  async summary(): Promise<VisitorStatsSummaryResponseDto> {
    const totalVisitors = await this.prisma.visitorStat.count();

    const byGov = await this.prisma.visitorStat.groupBy({
      by: ['governorateId'],
      where: { governorateId: { not: null } },
      _count: true,
      orderBy: { _count: { governorateId: 'desc' } },
    });

    const govIds = byGov.map(g => g.governorateId).filter(Boolean) as string[];
    const govs = await this.prisma.governorate.findMany({ where: { id: { in: govIds } } });
    const govMap = new Map(govs.map(g => [g.id, g]));

    const byDel = await this.prisma.visitorStat.groupBy({
      by: ['delegationId', 'governorateId'],
      where: { delegationId: { not: null } },
      _count: true,
      orderBy: { _count: { delegationId: 'desc' } },
    });

    const delIds = byDel.map(d => d.delegationId).filter(Boolean) as string[];
    const dels = await this.prisma.delegation.findMany({ where: { id: { in: delIds } } });
    const delMap = new Map(dels.map(d => [d.id, d]));

    return {
      totalVisitors,
      byGovernorate: byGov.map(g => {
        const gov = govMap.get(g.governorateId!);
        return {
          governorateId: g.governorateId!,
          governorateName: gov?.nameAr ?? '',
          governorateNameAr: gov?.nameAr ?? '',
          governorateNameFr: gov?.nameFr ?? '',
          count: g._count,
        };
      }),
      byDelegation: byDel.map(d => {
        const del = delMap.get(d.delegationId!);
        return {
          delegationId: d.delegationId!,
          delegationName: del?.nameAr ?? '',
          delegationNameAr: del?.nameAr ?? '',
          delegationNameFr: del?.nameFr ?? '',
          governorateId: d.governorateId!,
          count: d._count,
        };
      }),
    };
  }
}
