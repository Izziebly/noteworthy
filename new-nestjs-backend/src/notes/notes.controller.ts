import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { NotesService } from './notes.service';
import { AuthGuard } from '../auth/guards/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ParseMongoIdPipe } from '../common/pipes/parse-mongo-id.pipe';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';
import { NoteQueryDto } from './dto/note-query.dto';
import { type UserDocument } from '../auth/schemas/user.schema';

@Controller('notes')
@UseGuards(AuthGuard)
export class NotesController {
  constructor(private notesService: NotesService) {}

  /* ── GET /api/notes ── */
  @Get()
  async findAll(
    @CurrentUser() user: UserDocument,
    @Query() query: NoteQueryDto,
  ) {
    return this.notesService.findAll(user._id.toString(), query);
  }

  /* ── GET /api/notes/:id ── */
  @Get(':id')
  async findOne(
    @CurrentUser() user: UserDocument,
    @Param('id', ParseMongoIdPipe) id: string,
  ) {
    return this.notesService.findOne(id, user._id.toString());
  }

  /* ── POST /api/notes ── */
  @Post()
  async create(@CurrentUser() user: UserDocument, @Body() dto: CreateNoteDto) {
    return this.notesService.create(dto, user._id.toString());
  }

  /* ── PUT /api/notes/:id ── */
  @Put(':id')
  async update(
    @CurrentUser() user: UserDocument,
    @Param('id', ParseMongoIdPipe) id: string,
    @Body() dto: UpdateNoteDto,
  ) {
    return this.notesService.update(id, dto, user._id.toString());
  }

  /* ── DELETE /api/notes/:id ── */
  @Delete(':id')
  async remove(
    @CurrentUser() user: UserDocument,
    @Param('id', ParseMongoIdPipe) id: string,
  ) {
    return this.notesService.remove(id, user._id.toString());
  }
}
