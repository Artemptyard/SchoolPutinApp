# Create your models here.
from django.db import models
from users.models import Student
from schedule.models import Subject


class Gradebook(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='grades')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE)

    date = models.DateField()
    grade = models.IntegerField()
    comment = models.TextField(blank=True)

    class Meta:
        verbose_name = "Оценка"
        verbose_name_plural = "Журнал оценок"
        ordering = ['-date']

    def __str__(self):
        return f"{self.student.user.last_name} - {self.subject.name} - {self.grade} ({self.date})"
