using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;

namespace HostelManagement.DAL
{
    public static class PasswordHelper
    {
        private const int SaltSize = 16;       // 128-bit salt
        private const int KeySize = 32;       // 256-bit hash
        private const int Iterations = 100000;   // work factor
        private const char Delimiter = '.';

        /// <summary>Hash a plain-text password for storage.</summary>
        public static string HashPassword(string password)
        {
            byte[] salt = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }

            // NOTE: this overload uses SHA1 (works on all .NET Framework versions).
            // On .NET 4.7.2+ you can pass HashAlgorithmName.SHA256 as a 4th arg.
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                byte[] hash = pbkdf2.GetBytes(KeySize);

                return string.Format("{0}{3}{1}{3}{2}",
                    Iterations,
                    Convert.ToBase64String(salt),
                    Convert.ToBase64String(hash),
                    Delimiter);
            }
        }

        /// <summary>Verify a plain-text password against a stored hash.</summary>
        public static bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrEmpty(storedHash))
                return false;

            string[] parts = storedHash.Split(Delimiter);

            // Transitional fallback: if the stored value is NOT a PBKDF2 hash
            // (e.g. the seeded plain-text 'Admin@123'), compare directly.
            // TODO: remove this fallback once all passwords are hashed.
            if (parts.Length != 3)
                return password == storedHash;

            int iterations = int.Parse(parts[0]);
            byte[] salt = Convert.FromBase64String(parts[1]);
            byte[] expected = Convert.FromBase64String(parts[2]);

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations))
            {
                byte[] actual = pbkdf2.GetBytes(expected.Length);
                return FixedTimeEquals(actual, expected);
            }
        }

        /// <summary>Constant-time comparison to avoid timing attacks.</summary>
        private static bool FixedTimeEquals(byte[] a, byte[] b)
        {
            if (a.Length != b.Length) return false;
            int diff = 0;
            for (int i = 0; i < a.Length; i++)
                diff |= a[i] ^ b[i];
            return diff == 0;
        }
    }
}