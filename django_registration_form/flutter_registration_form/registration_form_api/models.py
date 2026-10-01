from django.db import models
from django.contrib.auth.models import User
from phonenumber_field.modelfields import PhoneNumberField
# Create your models here.

class UserProfile(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="user_profile")
    date_of_birth = models.DateField()
    phone_number = PhoneNumberField(unique=True, blank=False, null=False)
    
    def __str__(self):
        return f"{self.user.username} (DOB: {self.date_of_birth})"