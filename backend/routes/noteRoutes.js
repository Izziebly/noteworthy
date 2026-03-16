import express from "express";
import Note from "../models/Note.js";
import authMiddleware from "../middleware/authMiddleware.js";
import { slugify } from "../utils/slugify.js";

const router = express.Router();

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { title, content } = req.body;

    let slug = slugify(title);

    const existing = await Note.findOne({ user: req.user._id, slug });
    if (existing) slug = `${slug}-${Date.now()}`;

    const note = await Note.create({
      title,
      content,
      slug,
      user: req.user._id,
    });
    res.status(201).json(note);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.get("/", authMiddleware, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const skip = (page - 1) * limit;

    const search = req.query.search || "";

    const notes = await Note.find({
      user: req.user._id,
      $or: [
        { title: { $regex: search, $options: "i" } },
        { content: { $regex: search, $options: "i" } },
      ],
    })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Note.countDocuments({
      user: req.user._id,
    });

    res.json({
      total,
      page,
      pages: Math.ceil(total / limit),
      notes,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id", authMiddleware, async (req, res) => {
  try {
    const note = await Note.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!note) {
      return res.status(404).json({ message: "Note not found" });
    }

    res.json(note);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/:id", authMiddleware, async (req, res) => {
  try {
    const note = await Note.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!note) {
      return res.status(404).json({ message: "Note not found" });
    }

    if (req.body.title && req.body.title !== note.title) {
      let newSlug = slugify(req.body.title);
      const existing = await Note.findOne({
        user: req.user._id,
        slug: newSlug,
        _id: { $ne: note._id },
      });
      if (existing) newSlug = `${newSlug}-${Date.now()}`;
      note.slug = newSlug;
    }

    note.title = req.body.title || note.title;
    note.content = req.body.content || note.content;

    const updatedNote = await note.save();

    res.json(updatedNote);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const note = await Note.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!note) {
      return res.status(404).json({ message: "Note not found" });
    }

    res.json({ message: "Note deleted" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

export default router;
