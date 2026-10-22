import { Controller, Post, Body, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NearestLocationDto, NearestLocationResponseDto } from './dto/geolocation.dto';

@Controller('api/geolocation')
export class GeolocationController {
  constructor(private prisma: PrismaService) {}

  @Post('nearest')
  async findNearest(@Body() dto: NearestLocationDto): Promise<NearestLocationResponseDto> {
    const govs = await this.prisma.governorate.findMany();
    if (govs.length === 0) throw new NotFoundException('No governorates found');
    let closest = govs[0];
    let minDist = Infinity;

    for (const g of govs) {
      const dist = Math.pow(g.latitude - dto.latitude, 2) + Math.pow(g.longitude - dto.longitude, 2);
      if (dist < minDist) {
        minDist = dist;
        closest = g;
      }
    }

    // Find closest delegation
    const delegations = await this.prisma.delegation.findMany({ where: { governorateId: closest.id } });
    let closestDel = delegations.length > 0 ? delegations[0] : null;

    if (closestDel && delegations.length > 1) {
      let minDelDist = Infinity;
      for (const d of delegations) {
        if (d.latitude != null && d.longitude != null) {
          const dist = Math.pow(d.latitude - dto.latitude, 2) + Math.pow(d.longitude - dto.longitude, 2);
          if (dist < minDelDist) {
            minDelDist = dist;
            closestDel = d;
          }
        }
      }
    }

    return {
      governorate: { id: closest.id, name: closest.name, nameAr: closest.nameAr, nameFr: closest.nameFr },
      delegation: closestDel ? { id: closestDel.id, name: closestDel.name, nameAr: closestDel.nameAr, nameFr: closestDel.nameFr } : null,
    };
  }
}
