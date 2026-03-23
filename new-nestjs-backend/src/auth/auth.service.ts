import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Model } from 'mongoose';
import bcrypt from 'bcrypt';
import { User, UserDocument } from './schemas/user.schema';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

interface JwtPayload {
  id: string;
}
@Injectable()
export class AuthService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  /* ── Register ── */
  async register(dto: RegisterDto) {
    const existing = await this.userModel.findOne({
      username: dto.username,
    });
    if (existing) {
      throw new ConflictException('Username already taken');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    await this.userModel.create({
      username: dto.username,
      password: hashedPassword,
    });

    return { message: 'User registered successfully' };
  }

  /* ── Login ── */
  async login(dto: LoginDto) {
    const user = await this.userModel.findOne({ username: dto.username });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(dto.password, user.password);
    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const accessToken = this.generateAccessToken(user._id.toString());
    const refreshToken = this.generateRefreshToken(user._id.toString());

    // store hashed refresh token in DB
    user.refreshToken = await bcrypt.hash(refreshToken, 10);
    await user.save();

    return {
      accessToken,
      refreshToken,
      user: {
        _id: user._id,
        username: user.username,
      },
    };
  }

  /* ── Logout ── */
  async logout(refreshToken: string) {
    if (!refreshToken) {
      throw new BadRequestException('Refresh token required');
    }

    const decoded = this.jwtService.verify<JwtPayload>(refreshToken, {
      secret: this.configService.get<string>('REFRESH_SECRET'),
    });

    const user = await this.userModel.findById(decoded.id);
    if (user) {
      user.refreshToken = null;
      await user.save();
    }

    return { message: 'Logged out successfully' };
  }

  /* ── Refresh ── */
  async refresh(refreshToken: string) {
    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token required');
    }

    let decoded: { id: string };

    try {
      decoded = this.jwtService.verify<JwtPayload>(refreshToken, {
        secret: this.configService.get<string>('REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const user = await this.userModel.findById(decoded.id);
    if (!user || !user.refreshToken) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokenMatch = await bcrypt.compare(refreshToken, user.refreshToken);
    if (!tokenMatch) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const newAccessToken = this.generateAccessToken(user._id.toString());

    return {
      accessToken: newAccessToken,
      user: {
        _id: user._id,
        username: user.username,
      },
    };
  }

  /* ── Validate user by ID (used by guard) ── */
  async validateUserById(id: string) {
    return this.userModel.findById(id).select('-password -refreshToken');
  }

  /* ── Token generators ── */
  private generateAccessToken(userId: string) {
    return this.jwtService.sign(
      { id: userId },
      {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: '15m',
      },
    );
  }

  private generateRefreshToken(userId: string) {
    return this.jwtService.sign(
      { id: userId },
      {
        secret: this.configService.get<string>('REFRESH_SECRET'),
        expiresIn: '7d',
      },
    );
  }
}
