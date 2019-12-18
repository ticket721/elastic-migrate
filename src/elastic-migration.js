class ElasticMigration {
  constructor(client) {
    this.client = client;
    this.logPrefix = "\t[ElasticMigration]";
  }
  log(message) {
    console.log(`${this.logPrefix} ${message}`);
  }
  error(message) {
    console.error(`\t${this.logPrefix} ${message}`);
  }

  async up() {
    throw new Error("Not implemented");
  }
  async down() {
    throw new Error("Not implemented");
  }

  async createIndex(indexName, keyspaceName) {
    this.log(`creating index=${indexName}`);
    await this.client.indices.create({
      index: indexName,
      body: {
        settings: {
          keyspace: keyspaceName
        }
      },
    });
    return this.client.indices.refresh({
      index: indexName,
    });
  }

  async putMapping(indexName, mappingName, mappingBody) {
    this.log(`putting mapping=${indexName}:${mappingName}`);
    return this.client.indices.putMapping({
      index: indexName,
      type: mappingName,
      body: mappingBody
    });
  }

  async putSettings(indexName, settings) {
    this.log(`putting index settings=${indexName}`);
    return this.client.indices.putSettings({
      index: indexName,
      body: settings
    });
  }

  async openIndex(indexName) {
    this.log(`opening index settings=${indexName}`);
    return this.client.indices.open({
      index: indexName
    });
  }

  async closeIndex(indexName) {
    this.log(`closing index settings=${indexName}`);
    return this.client.indices.open({
      index: indexName
    });
  }


  async putSettings(indexName, settings) {
    this.log(`putting index settings=${indexName}`);
    return this.client.indices.putSettings({
      index: indexName,
      body: settings
    });
  }

  async removeIndex(indexName) {
    this.log(`removing index=${indexName}`);
    return  this.client.indices.delete({ index: indexName });
  }
  async addAlias(aliasName, indexName) {
    this.log(`adding alias index=${indexName} alias=${aliasName}`);
    return  this.client.indices.putAlias({ name: aliasName, index: indexName });
  }
  async removeAlias(aliasName, indexName) {
    this.log(`removing alias index=${indexName} alias=${aliasName}`);
    return  this.client.indices.deleteAlias({ name: aliasName, index: indexName });
  }
}

module.exports = ElasticMigration;
