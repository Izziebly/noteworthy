import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Note, NoteDocument } from './schemas/note.schema';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';
import { NoteQueryDto } from './dto/note-query.dto';
import { slugify } from '../utils/slugify';

@Injectable()
export class NotesService {
  constructor(@InjectModel(Note.name) private noteModel: Model<NoteDocument>) {}

  /* ── GET all notes (paginated + search) ── */
  async findAll(userId: string, query: NoteQueryDto) {
    const page = parseInt(query.page ?? '1');
    const limit = parseInt(query.limit ?? '10');
    const skip = (page - 1) * limit;
    const search = query.search ?? '';

    const filter = {
      user: new Types.ObjectId(userId),
      ...(search && {
        $or: [
          { title: { $regex: search, $options: 'i' } },
          { content: { $regex: search, $options: 'i' } },
        ],
      }),
    };

    const [notes, total] = await Promise.all([
      this.noteModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      this.noteModel.countDocuments(filter),
    ]);

    return {
      total,
      page,
      pages: Math.ceil(total / limit),
      notes,
    };
  }

  /* ── GET single note by ID ── */
  async findOne(id: string, userId: string) {
    const note = await this.noteModel.findOne({
      _id: id,
      user: new Types.ObjectId(userId),
    });

    if (!note) throw new NotFoundException('Note not found');
    return note;
  }

  /* ── POST create note ── */
  async create(dto: CreateNoteDto, userId: string) {
    let slug = slugify(dto.title);

    /* ── Handle duplicate slugs ── */
    const existing = await this.noteModel.findOne({
      user: new Types.ObjectId(userId),
      slug,
    });
    if (existing) slug = `${slug}-${Date.now()}`;

    return this.noteModel.create({
      title: dto.title,
      content: dto.content,
      slug,
      user: new Types.ObjectId(userId),
    });
  }

  /* ── PUT update note ── */
  async update(id: string, dto: UpdateNoteDto, userId: string) {
    const note = await this.noteModel.findOne({
      _id: id,
      user: new Types.ObjectId(userId),
    });

    if (!note) throw new NotFoundException('Note not found');

    /* ── Regenerate slug if title changed ── */
    if (dto.title && dto.title !== note.title) {
      let newSlug = slugify(dto.title);
      const existing = await this.noteModel.findOne({
        user: new Types.ObjectId(userId),
        slug: newSlug,
        _id: { $ne: note._id },
      });
      if (existing) newSlug = `${newSlug}-${Date.now()}`;
      note.slug = newSlug;
    }

    if (dto.title) note.title = dto.title;
    if (dto.content) note.content = dto.content;

    return note.save();
  }

  /* ── DELETE note ── */
  async remove(id: string, userId: string) {
    const note = await this.noteModel.findOneAndDelete({
      _id: id,
      user: new Types.ObjectId(userId),
    });

    if (!note) throw new NotFoundException('Note not found');
    return { message: 'Note deleted' };
  }
}
