from django.db import models
from users.models import Student, Teacher

# Create your models here.
class Subject(models.Model):
    LEVELS = [('low', 'Подготовительный'), ('medium', 'ОГЭ'), ('hign', 'ЕГЭ')]
    name = models.CharField(max_length=100)
    description = models.CharField(max_length=300, blank=True)
    level = models.CharField(choices=LEVELS, max_length=20)
    teachers = models.ManyToManyField(Teacher, related_name='subjects')

    def __str__(self):
        return self.name


class Group(models.Model):
    name = models.CharField(max_length=50)
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
    students = models.ManyToManyField(Student, related_name='groups')

    def __str__(self):
        return self.name


class Schedule(models.Model):
    DAY_CHOICES = [
        ('mon', 'Понедельник'),
        ('tue', 'Вторник'),
        ('wed', 'Среда'),
        ('thu', 'Четверг'),
        ('fri', 'Пятница'),
        ('sat', 'Суббота'),
        ('sun', 'Воскресенье'),
    ]

    day = models.CharField(max_length=3, choices=DAY_CHOICES)
    time = models.TimeField()
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='schedules')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='schedules')
    teacher = models.ForeignKey(Teacher, on_delete=models.SET_NULL, null=True, related_name='schedules')

    def __str__(self):
        return f"{self.day} {self.time} - {self.group} - {self.subject}"