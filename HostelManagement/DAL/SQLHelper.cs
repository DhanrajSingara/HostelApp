using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace HostelManagement.DAL
{
    public static class SQLHelper
    {
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        /// <summary>
        /// Execute Query (SELECT)
        /// </summary>
        public static async Task<DataTable> ExecuteQueryAsync(string query)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                await con.OpenAsync();
                da.Fill(dt);
            }

            return dt;
        }

        /// <summary>
        /// Execute Stored Procedure With SqlParameters
        /// </summary>
        public static async Task<DataTable> ExecuteSPAsync(
            string spName,
            params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(spName, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    await con.OpenAsync();
                    da.Fill(dt);
                }
            }

            return dt;
        }

        /// <summary>
        /// Execute Stored Procedure Without Parameters
        /// </summary>
        public static async Task<DataTable> ExecuteSPAsync(string spName)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(spName, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    await con.OpenAsync();
                    da.Fill(dt);
                }
            }

            return dt;
        }

        /// <summary>
        /// Execute Stored Procedure With Hashtable Parameters
        /// </summary>
        public static async Task<DataTable> ExecuteSPParamsAsync(
            string spName,
            Hashtable ht)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(spName, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 80;

                if (ht != null)
                {
                    foreach (DictionaryEntry de in ht)
                    {
                        cmd.Parameters.AddWithValue(
                            de.Key.ToString(),
                            de.Value ?? DBNull.Value);
                    }
                }

                await con.OpenAsync();

                using (SqlDataReader dr = await cmd.ExecuteReaderAsync())
                {
                    dt.Load(dr);
                }
            }

            return dt;
        }

        /// <summary>
        /// Execute Insert / Update / Delete Query
        /// </summary>
        public static async Task<int> ExecuteNonQueryAsync(
            string query,
            CommandType commandType = CommandType.Text,
            params SqlParameter[] parameters)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.CommandType = commandType;

                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                await con.OpenAsync();

                return await cmd.ExecuteNonQueryAsync();
            }
        }

        /// <summary>
        /// Execute Insert / Update / Delete Stored Procedure With Hashtable
        /// </summary>
        public static async Task<int> ExecuteNonQueryParamsAsync(
            string spName,
            Hashtable ht)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(spName, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 80;

                if (ht != null)
                {
                    foreach (DictionaryEntry de in ht)
                    {
                        cmd.Parameters.AddWithValue(
                            de.Key.ToString(),
                            de.Value ?? DBNull.Value);
                    }
                }

                await con.OpenAsync();

                return await cmd.ExecuteNonQueryAsync();
            }
        }
    }
}