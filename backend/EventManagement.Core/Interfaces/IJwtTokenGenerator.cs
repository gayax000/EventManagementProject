using EventManagement.Core.Entities;

namespace EventManagement.Core.Interfaces;

public interface IJwtTokenGenerator
{
    string GenerateToken(User user, string roleName);
}
