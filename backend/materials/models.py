from django.db import models
from schedule.models import Subject
from users.models import Teacher

# Create your models here.
class Material(models.Model):
    title = models.CharField("Название материала", max_length=200)
    description = models.TextField("Описание", blank=True)
    file = models.FileField("Файл", upload_to="materials/", blank=True)
    upload_date = models.DateTimeField(auto_now_add=True)

    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='materials')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='materials')

    class Meta:
        verbose_name = "Учебный материал"
        verbose_name_plural = "Учебные материалы"
        ordering = ['-upload_date']

    def __str__(self):
        return f"{self.title} ({self.subject.name})"