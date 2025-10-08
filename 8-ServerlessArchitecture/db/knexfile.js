import AWS from 'aws-sdk';

const getDatabaseConnectionString = async () => {
    const secretsManager = new AWS.SecretsManager({
        region: process.env.AWS_REGION,
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    });

    const secretName = process.env.AWS_SECRETSMANAGER_SECRET_NAME;

    const response = await secretsManager
        .getSecretValue({ SecretId: secretName })
        .promise();

    if (!response.SecretString) {
        throw new Error(`Secret "${secretName}" has no string content.`);
    }

    const secretJson = JSON.parse(response.SecretString);

    if (!secretJson.db_conn_string) {
        throw new Error(`"db_conn_string" not found in secret "${secretName}".`);
    }

    return secretJson.db_conn_string;
};

export default {
    development: {
        client: 'pg',
        connection: async () => {
            try {
                const connectionString = await getDatabaseConnectionString();
                return connectionString;
            } catch (err) {
                console.error('Failed to retrieve DB connection string:', err);
                throw err;
            }
        },
        migrations: {
            directory: './migrations',
        },
        debug: true,
    },
};
