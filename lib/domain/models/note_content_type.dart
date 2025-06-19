sealed class NoteContentType {
  const NoteContentType();
}

class NoteContentText extends NoteContentType{
  const NoteContentText();
}
class NoteContentMedia extends NoteContentType{
  const NoteContentMedia();
}
class NoteContentUnknown extends NoteContentType{
  const NoteContentUnknown();
}
